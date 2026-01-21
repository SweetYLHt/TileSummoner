## 地形编辑界面UI控制器
##
## 管理地形编辑界面的UI显示和交互
extends Control
class_name TileEditorUI

## 地块选择按钮场景
const TILE_PALETTE_ITEM_SCENE = preload("res://Scenes/ui/tile_palette_item.tscn")

## 控制器引用
@onready var _controller: TileEditorController = $TileEditorController

## UI节点引用
@onready var _tile_list: VBoxContainer = $MainHSplit/LeftPanel/Scroll/TileList
@onready var _difficulty_option: OptionButton = $TopBar/DifficultyOption
@onready var _start_button: Button = $TopBar/StartBattleButton
@onready var _back_button: Button = $TopBar/BackButton
@onready var _reset_button: Button = $MainHSplit/LeftPanel/ResetButton
@onready var _status_label: Label = $StatusBar/StatusLabel
@onready var _selected_label: Label = $MainHSplit/RightPanel/InfoPanel/SelectedLabel
@onready var _placed_label: Label = $MainHSplit/RightPanel/InfoPanel/PlacedLabel

## 地形选择按钮字典
var _tile_items: Dictionary = {}

## 当前选中的按钮
var _selected_item: TilePaletteItem = null


func _ready() -> void:
	_connect_signals()
	_setup_difficulty_options()

	# 延迟初始化控制器（等待场景完全加载）
	call_deferred("_initialize_controller")


## 延迟初始化控制器
func _initialize_controller() -> void:
	# 设置控制器引用
	_controller.grid_manager = $MainHSplit/RightPanel/GridContainer/GridManager
	_controller.tile_inventory = $TileEditorController/TileInventory
	_controller.map_generator = $TileEditorController/BattleMapGenerator

	_controller.initialize()

	# 构建地形列表（需要 tile_inventory 已初始化）
	_build_tile_list()

	# 更新UI
	_update_ui()

	# 连接地块点击信号
	_connect_tile_signals()


## 连接信号
func _connect_signals() -> void:
	_start_button.pressed.connect(_on_start_battle_pressed)
	_back_button.pressed.connect(_on_back_pressed)
	_reset_button.pressed.connect(_on_reset_pressed)
	_difficulty_option.item_selected.connect(_on_difficulty_changed)

	_controller.tile_selected.connect(_on_tile_selected)
	_controller.tile_placed.connect(_on_tile_placed)
	_controller.config_changed.connect(_on_config_changed)


## 设置难度选项
func _setup_difficulty_options() -> void:
	_difficulty_option.clear()
	_difficulty_option.add_item("简单", 0)
	_difficulty_option.add_item("中等", 1)
	_difficulty_option.add_item("困难", 2)
	_difficulty_option.selected = 0


## 构建地形选择列表
func _build_tile_list() -> void:
	# 清空现有项
	for child in _tile_list.get_children():
		child.queue_free()
	_tile_items.clear()

	# 获取所有地形类型
	var tile_types := tileDatabase.get_all_tile_types()

	for tile_type in tile_types:
		var item: TilePaletteItem = TILE_PALETTE_ITEM_SCENE.instantiate()
		item.setup(tile_type, _controller.tile_inventory)
		item.pressed.connect(_on_tile_item_pressed.bind(tile_type))

		_tile_list.add_child(item)
		_tile_items[tile_type] = item


## 地形选择按钮点击
func _on_tile_item_pressed(tile_type: TileConstants.TileType) -> void:
	_controller.select_tile(tile_type)


## 控制器：地形被选中
func _on_tile_selected(tile_type: TileConstants.TileType) -> void:
	# 取消之前的选中
	if _selected_item:
		_selected_item.set_selected(false)

	# 选中新的
	if _tile_items.has(tile_type):
		_selected_item = _tile_items[tile_type]
		_selected_item.set_selected(true)

	_update_selected_info()


## 控制器：地形被放置
func _on_tile_placed(_cell: Vector2i, _tile_type: TileConstants.TileType) -> void:
	_update_tile_counts()
	_update_placed_info()


## 控制器：配置变更
func _on_config_changed() -> void:
	_update_tile_counts()
	_update_placed_info()
	_update_status_label()


## 开始战斗按钮
func _on_start_battle_pressed() -> void:
	_controller.start_battle()


## 返回按钮
func _on_back_pressed() -> void:
	_controller.go_back()


## 重置按钮
func _on_reset_pressed() -> void:
	_controller.reset_config()
	_rebuild_tile_list()


## 难度变更
func _on_difficulty_changed(index: int) -> void:
	var difficulties: Array[TileConstants.ConfigType] = [
		TileConstants.ConfigType.ENEMY_EASY,
		TileConstants.ConfigType.ENEMY_MEDIUM,
		TileConstants.ConfigType.ENEMY_HARD,
	]
	if index >= 0 and index < difficulties.size():
		_controller.set_enemy_difficulty(difficulties[index])


## 重建地形列表
func _rebuild_tile_list() -> void:
	for tile_type in _tile_items:
		var item: TilePaletteItem = _tile_items[tile_type]
		item.update_count()


## 更新所有地形数量显示
func _update_tile_counts() -> void:
	for tile_type in _tile_items:
		var item: TilePaletteItem = _tile_items[tile_type]
		item.update_count()


## 更新选中信息
func _update_selected_info() -> void:
	var selected := _controller.get_selected_tile()
	if selected >= 0:
		var tile_type: TileConstants.TileType = selected as TileConstants.TileType
		var display_name := tileDatabase.get_tile_display_name(tile_type)
		var count := _controller.tile_inventory.get_count(tile_type)
		_selected_label.text = "当前选中: %s (库存: %d)" % [display_name, count]
	else:
		_selected_label.text = "当前选中: 无"


## 更新已放置信息
func _update_placed_info() -> void:
	var placed := _controller.get_placed_count()
	var total := _controller.get_total_cells()
	_placed_label.text = "已编辑: %d/%d 格" % [placed, total]


## 更新状态栏
func _update_status_label() -> void:
	var difficulty := _controller.get_enemy_difficulty()
	var difficulty_name: String = TileConstants.get_config_type_name(difficulty)
	var total := _controller.tile_inventory.get_total_count()
	_status_label.text = "准备就绪 | 敌方难度: %s | 可用地块: %d" % [difficulty_name, total]


## 更新UI
func _update_ui() -> void:
	_update_tile_counts()
	_update_selected_info()
	_update_placed_info()
	_update_status_label()


## 连接地块拖拽信号
func _connect_tile_signals() -> void:
	var tiles = _controller.grid_manager.get_all_tiles()
	for tile in tiles:
		if tile.is_editable:
			# 只连接拖拽放置信号
			if not tile.drop_received.is_connected(_on_drop_on_tile):
				tile.drop_received.connect(_on_drop_on_tile)


## ============ 拖拽功能 ============

## 处理拖拽放置到地块
func _on_drop_on_tile(target_tile: Tile, data: Dictionary) -> void:
	if not target_tile or not target_tile.is_editable:
		return

	var source: String = data.get("source", "")
	var target_cell: Vector2i = target_tile.grid_position

	if source == "inventory":
		# 从库存拖拽
		var tile_type: TileConstants.TileType = data.tile_type
		_debug_log_ui_place("inventory", target_cell, tile_type)
		_controller.place_tile_from_inventory(target_cell, tile_type)

	elif source == "board":
		# 从棋盘内拖拽（交换两个地块）
		var source_tile: Tile = data.source_tile
		var source_cell: Vector2i = source_tile.grid_position
		_debug_log_ui_swap(source_cell, target_cell, source_tile.get_data().tile_type, target_tile.get_data().tile_type)
		_controller.swap_tiles_on_board(source_cell, target_cell)


## UI 放置调试日志
func _debug_log_ui_place(source: String, cell: Vector2i, tile_type: TileConstants.TileType) -> void:
	var tile_name := tileDatabase.get_tile_display_name(tile_type)
	print("[UI PLACE] source=%s cell=%s type=%s(%d)" % [source, cell, tile_name, tile_type])


## UI 交换调试日志
func _debug_log_ui_swap(cell_a: Vector2i, cell_b: Vector2i, type_a: TileConstants.TileType, type_b: TileConstants.TileType) -> void:
	var name_a := tileDatabase.get_tile_display_name(type_a)
	var name_b := tileDatabase.get_tile_display_name(type_b)
	print("[UI SWAP] from=%s(%s) to=%s(%s)" % [cell_a, name_a, cell_b, name_b])
