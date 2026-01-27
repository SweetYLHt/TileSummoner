## 地形配置 UI 主控制器
extends Control
class_name TerrainConfigUI

## 信号：配置完成
signal config_completed(config_data: Dictionary)

## 信号：返回
signal back_requested()

## ============================================================================
## 导出变量
## ============================================================================

## 配置数据资源（可用地形列表）
@export var config_data: Resource = null

## 默认预设配置（TileConfig 类型）
@export var default_preset_config: TileConfig = null

## 网格行数
@export var grid_rows: int = 4

## 网格列数
@export var grid_columns: int = 7

## ============================================================================
## 节点引用
## ============================================================================

@onready var _difficulty_option: OptionButton = $VBoxContainer/Header/HBoxContainer/DifficultyOption
@onready var _back_button: Button = $VBoxContainer/Header/HBoxContainer/BackButton
@onready var _start_button: Button = $VBoxContainer/Header/HBoxContainer/StartButton
@onready var _terrain_list_container: VBoxContainer = $VBoxContainer/ContentHSplit/Sidebar/VBoxContainer/TerrainList/TerrainListContainer
@onready var _grid_container: GridContainer = $VBoxContainer/ContentHSplit/MainArea/VBoxContainer/CenterContainer/GridContainer
@onready var _reset_button: Button = $VBoxContainer/Footer/HBoxContainer/ResetButton

## ============================================================================
## 内部变量
## ============================================================================

## 网格槽位数组
var _grid_slots: Array[TerrainGridSlot] = []

## 地形列表项数组
var _terrain_list_items: Array[TerrainListItem] = []

## 当前配置类型
var _current_config_type: TileConstants.ConfigType = TileConstants.ConfigType.PLAYER_DEFAULT

## 网格配置数据 [row][col] = terrain_type
var _grid_config: Array = []

## 当前拖拽数据
var _drag_data: Dictionary = {}

## 图标纹理缓存
var _icon_cache: Dictionary = {}

## TileInventory 引用（AutoLoad 单例）
@onready var _tile_inventory: TileInventory = get_node("/root/tileInventory")

## ============================================================================
## Godot 生命周期
## ============================================================================

func _ready() -> void:
	# 初始化网格配置数组
	_init_grid_config()

	# 设置网格列数
	_grid_container.columns = grid_columns

	# 连接信号
	_connect_signals()

	# 加载配置数据
	if config_data:
		_load_config_data()

	# 创建 UI
	_create_grid_slots()
	_create_terrain_list()

	# 加载默认预设配置
	if default_preset_config:
		_load_preset_config(default_preset_config)

	# 预加载图标
	_preload_icons()

	# 初始化库存
	if _tile_inventory:
		_tile_inventory.initialize_default_inventory()
		_sync_inventory_to_ui()


func _input(event: InputEvent) -> void:
	# 处理 Escape 键返回
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


## ============================================================================
## 初始化
## ============================================================================

## 初始化网格配置数组
func _init_grid_config() -> void:
	_grid_config.clear()
	for row in grid_rows:
		var row_array: Array = []
		for col in grid_columns:
			row_array.append(-1) # -1 表示空
		_grid_config.append(row_array)


## 连接信号
func _connect_signals() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	_start_button.pressed.connect(_on_start_pressed)
	_reset_button.pressed.connect(_on_reset_pressed)
	_difficulty_option.item_selected.connect(_on_difficulty_changed)


## 加载配置数据
func _load_config_data() -> void:
	if not config_data:
		return

	var entries: Array[TerrainEntryResource] = config_data.terrain_entries
	for entry: TerrainEntryResource in entries:
		if entry:
			# 可以在这里加载额外的配置信息
			pass


## 加载预设配置
func _load_preset_config(preset: TileConfig) -> void:
	if not preset:
		return

	# 获取玩家区域配置（4×7 = 28个地块）
	var tiles: Array[TileConstants.TileType] = preset.get_player_tiles()

	# 检查数量是否匹配
	var expected_size: int = grid_rows * grid_columns
	if tiles.size() != expected_size:
		push_warning("预设配置大小不匹配: 期望 %d, 实际 %d" % [expected_size, tiles.size()])
		return

	# 将一维数组转换为二维网格配置
	_grid_config.clear()
	for row in range(grid_rows):
		var row_array: Array = []
		for col in range(grid_columns):
			var index: int = row * grid_columns + col
			row_array.append(tiles[index])
		_grid_config.append(row_array)

	# 更新所有槽位显示
	_update_all_slots()


## 创建网格槽位
func _create_grid_slots() -> void:
	# 清除现有槽位
	for slot: TerrainGridSlot in _grid_slots:
		slot.queue_free()
	_grid_slots.clear()

## 创建新槽位
	var total_slots: int = grid_rows * grid_columns
	for i in range(total_slots):
		var slot: TerrainGridSlot = preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
		slot.set_grid_position(i / grid_columns, i % grid_columns)
		slot.drop_data_received.connect(_on_slot_drop_data)
		_grid_container.add_child(slot)
		_grid_slots.append(slot)


## 创建地形列表
func _create_terrain_list() -> void:
	# 清除现有列表项
	for item: TerrainListItem in _terrain_list_items:
		item.queue_free()
	_terrain_list_items.clear()

	if not config_data:
		return

	var entries: Array[TerrainEntryResource] = config_data.terrain_entries
	for entry: TerrainEntryResource in entries:
		if entry:
			var item: TerrainListItem = preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
			item.setup(entry.tile_type, entry.available_count)
			item.drag_started.connect(_on_item_drag_started)
			_terrain_list_container.add_child(item)
			_terrain_list_items.append(item)


## 预加载图标
func _preload_icons() -> void:
	var all_types: Array[TileConstants.TileType] = TileConstants.get_all_tile_types()
	for tile_type: TileConstants.TileType in all_types:
		var data: TileBlockData = _get_tile_data(tile_type)
		if data and data.texture:
			_icon_cache[tile_type] = data.texture


## ============================================================================
## 公共方法
## ============================================================================

## 获取当前配置
func get_current_config() -> Dictionary:
	return {
		"config_type": _current_config_type,
		"grid": _grid_config.duplicate(true)
	}


## 重置配置
func reset_config() -> void:
	_init_grid_config()
	_update_all_slots()

	# 恢复库存
	if _tile_inventory:
		_tile_inventory.initialize_default_inventory()
		_sync_inventory_to_ui()


## 应用预设配置
func apply_preset(preset_data: Array) -> void:
	if preset_data.size() != grid_rows:
		return

	_grid_config = preset_data.duplicate(true)
	_update_all_slots()


## ============================================================================
## 内部方法
## ============================================================================

## 获取地块数据
func _get_tile_data(tile_type: TileConstants.TileType) -> TileBlockData:
	return tileDatabase.get_tile_data(tile_type)


## 更新所有槽位显示
func _update_all_slots() -> void:
	for slot: TerrainGridSlot in _grid_slots:
		var row: int = slot.get_grid_row()
		var col: int = slot.get_grid_col()
		var tile_type: int = _grid_config[row][col]
		slot.set_terrain(tile_type)


## 同步库存到 UI
func _sync_inventory_to_ui() -> void:
	for item: TerrainListItem in _terrain_list_items:
		var tile_type: TileConstants.TileType = item.get_tile_type()
		var count := _tile_inventory.get_count(tile_type) if _tile_inventory else 0
		item.update_count(count)


## ============================================================================
## 信号回调
## ============================================================================

## 返回按钮按下
func _on_back_pressed() -> void:
	back_requested.emit()


## 开始按钮按下
func _on_start_pressed() -> void:
	config_completed.emit(get_current_config())


## 重置按钮按下
func _on_reset_pressed() -> void:
	reset_config()


## 难度选择改变
func _on_difficulty_changed(index: int) -> void:
	_current_config_type = index as TileConstants.ConfigType
	# 可以根据难度加载不同的预设


## 地形列表项拖拽开始
func _on_item_drag_started(tile_type: TileConstants.TileType) -> void:
	_drag_data = {"tile_type": tile_type}


## 槽位接收拖拽数据
func _on_slot_drop_data(slot: TerrainGridSlot, data: Dictionary) -> void:
	if not data.has("tile_type"):
		return

	var row: int = slot.get_grid_row()
	var col: int = slot.get_grid_col()
	var tile_type: TileConstants.TileType = data["tile_type"]

	# 检查是否来自网格槽位（需要交换）
	if data.has("source_type") and data["source_type"] == "grid_slot":
		var from_row: int = data["from_row"]
		var from_col: int = data["from_col"]

		# 如果是同一个槽位，不做任何操作
		if from_row == row and from_col == col:
			return

		# 交换两个槽位的地形（无需库存操作）
		var temp_type: TileConstants.TileType = _grid_config[row][col]
		_grid_config[row][col] = _grid_config[from_row][from_col]
		_grid_config[from_row][from_col] = temp_type

		# 更新两个槽位的显示
		slot.set_terrain(_grid_config[row][col])
		slot.play_place_animation()

		# 找到源槽位并更新
		for source_slot: TerrainGridSlot in _grid_slots:
			if source_slot.get_grid_row() == from_row and source_slot.get_grid_col() == from_col:
				source_slot.set_terrain(_grid_config[from_row][from_col])
				break
	else:
		# 来自侧边栏，需要库存操作
		var old_type: TileConstants.TileType = _grid_config[row][col]

		# 检查库存
		if _tile_inventory and _tile_inventory.get_count(tile_type) <= 0:
			push_warning("库存不足: %s" % TileConstants.get_tile_type_name(tile_type))
			return

		# 消耗新地块
		if _tile_inventory:
			_tile_inventory.consume_tile(tile_type, 1)

		# 归还旧地块（如果不是空）
		if old_type >= 0 and _tile_inventory:
			_tile_inventory.add_tile(old_type, 1)

		# 更新配置
		_grid_config[row][col] = tile_type
		slot.set_terrain(tile_type)
		slot.play_place_animation()

		# 同步库存到 UI
		_sync_inventory_to_ui()


## ============================================================================
## 样式和动画
## ============================================================================

## 应用赛博朋克发光效果
func _apply_glow_effect(_control: Control) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# 这里可以添加更多视觉效果
	pass
