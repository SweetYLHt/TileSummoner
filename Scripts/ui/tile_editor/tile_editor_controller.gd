## 地形编辑控制器
##
## 处理地形编辑的核心逻辑
extends Node
class_name TileEditorController

## 编辑器专用网格配置
const EDITOR_GRID_CONFIG_PATH = "res://Resources/Tiles/Configs/grid_editor.tres"

## 地形选中信号
signal tile_selected(tile_type: TileConstants.TileType)

## 地形放置信号
signal tile_placed(cell: Vector2i, tile_type: TileConstants.TileType)

## 配置变更信号
signal config_changed()

## 外部引用（由场景设置）
var grid_manager: GridManager
var tile_inventory: TileInventory
var map_generator: BattleMapGenerator

## 当前选中的地形类型（使用 -1 表示未选中）
var _selected_tile_type: int = -1

## 当前敌方难度
var _enemy_difficulty: TileConstants.ConfigType = TileConstants.ConfigType.ENEMY_EASY

## 当前玩家配置（编辑后的）
var _current_player_config: Array[TileConstants.TileType] = []

## 原始玩家配置（用于重置）
var _original_player_config: Array[TileConstants.TileType] = []

## 编辑器网格配置
var _editor_grid_config: GridConfig = null


func _ready() -> void:
	# 初始化库存
	if tile_inventory:
		tile_inventory.initialize_default_inventory()


## 初始化编辑器
func initialize() -> void:
	if not grid_manager or not tile_inventory or not map_generator:
		push_error("TileEditorController: Missing required references")
		return

	# 加载编辑器专用网格配置
	_editor_grid_config = load(EDITOR_GRID_CONFIG_PATH) as GridConfig
	if not _editor_grid_config:
		push_error("Failed to load editor grid config from: %s" % EDITOR_GRID_CONFIG_PATH)
		return

	# 分配编辑器配置到网格管理器
	grid_manager.config = _editor_grid_config

	# 初始化库存
	tile_inventory.initialize_default_inventory()

	# 加载玩家配置
	var player_config := map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)

	if player_config:
		_original_player_config = player_config.get_player_tiles()
		_current_player_config = _original_player_config.duplicate()

	# 创建编辑器网格（只有我方4行）
	# 传入空数组作为敌方地块，因为编辑器不显示敌方区域
	grid_manager.create_grid([], _current_player_config)


## 选择地形类型
func select_tile(tile_type: TileConstants.TileType) -> void:
	if not tileDatabase.is_valid_tile_type(tile_type):
		return

	_selected_tile_type = tile_type
	tile_selected.emit(tile_type)


## 获取当前选中的地形
func get_selected_tile() -> int:
	return _selected_tile_type


## 是否有选中的地形
func has_selected_tile() -> bool:
	return _selected_tile_type >= 0


## 放置地形到指定格子
func place_tile(cell: Vector2i) -> bool:
	# 验证选中状态
	if _selected_tile_type < 0:
		return false

	var selected_type: TileConstants.TileType = _selected_tile_type as TileConstants.TileType

	# 验证格子位置（编辑器网格为4行：行0-3）
	var grid_height: int = grid_manager.get_grid_height() if grid_manager else 4
	var grid_width: int = grid_manager.get_grid_width() if grid_manager else 7
	if cell.x < 0 or cell.x >= grid_width or cell.y < 0 or cell.y >= grid_height:
		return false

	# 检查库存
	if tile_inventory.get_count(selected_type) <= 0:
		return false

	# 获取当前地块
	var tile = grid_manager.get_tile(cell)
	if not tile or not tile.is_editable:
		return false

	var old_type: TileConstants.TileType = tile.get_data().tile_type

	# 如果是相同类型，不执行操作
	if old_type == selected_type:
		return false

	# 消耗新地形库存
	if not tile_inventory.consume_tile(selected_type):
		return false

	# 归还旧地形库存
	tile_inventory.add_tile(old_type)

	# 更新地块
	grid_manager.replace_tile(cell, selected_type)

	# 更新配置数组（编辑器网格坐标直接对应配置索引）
	var config_idx := cell.y * grid_width + cell.x
	if config_idx >= 0 and config_idx < _current_player_config.size():
		_current_player_config[config_idx] = selected_type

	# 发送信号
	tile_placed.emit(cell, selected_type)
	config_changed.emit()

	return true


## 重置配置
func reset_config() -> void:
	# 清空当前库存
	tile_inventory.clear()

	# 重新初始化库存
	tile_inventory.initialize_default_inventory()

	# 恢复原始配置
	_current_player_config = _original_player_config.duplicate()

	# 重新生成网格（只生成玩家区域）
	grid_manager.create_grid([], _current_player_config)

	# 发送重置消息
	var msg := ConfigResetMessage.new()
	msg.reset_type = &"player"
	MessageServer.send_message(msg)

	config_changed.emit()


## 设置敌方难度
func set_enemy_difficulty(difficulty: TileConstants.ConfigType) -> void:
	if difficulty == _enemy_difficulty:
		return

	_enemy_difficulty = difficulty
	# 编辑器不显示敌方区域，无需重新生成网格
	config_changed.emit()


## 获取当前敌方难度
func get_enemy_difficulty() -> TileConstants.ConfigType:
	return _enemy_difficulty


## 获取可用敌方配置列表
func get_available_enemy_configs() -> Array[TileConstants.ConfigType]:
	return map_generator.get_available_enemy_configs()


## 开始战斗
func start_battle() -> void:
	# 设置敌方难度
	SceneManager.current_enemy_difficulty = _enemy_difficulty
	# 传递玩家编辑的配置
	SceneManager.set_player_config(_current_player_config.duplicate())

	# 切换到战斗场景
	SceneManager.transition_to_battle(_enemy_difficulty)


## 返回主菜单
func go_back() -> void:
	SceneManager.transition_to_main_menu()


## 获取已放置地块数量
func get_placed_count() -> int:
	var count := 0
	for tile_type in _current_player_config:
		if tile_type != TileConstants.TileType.GRASSLAND: # 草地是默认地形，不计入
			count += 1
	return count


## 获取总格子数
func get_total_cells() -> int:
	return 28 # 我方区域 4行 × 7列


## ============ 拖拽功能 ============

## 从库存拖拽放置地块
func place_tile_from_inventory(cell: Vector2i, tile_type: TileConstants.TileType) -> bool:
	# 1. 验证位置（编辑器网格为4行：行0-3）
	var grid_height: int = grid_manager.get_grid_height() if grid_manager else 4
	var grid_width: int = grid_manager.get_grid_width() if grid_manager else 7
	if cell.x < 0 or cell.x >= grid_width or cell.y < 0 or cell.y >= grid_height:
		return false

	# 2. 检查库存
	if tile_inventory.get_count(tile_type) <= 0:
		return false

	# 3. 获取当前地块
	var tile = grid_manager.get_tile(cell)
	if not tile or not tile.is_editable:
		return false

	var current_type: TileConstants.TileType = tile.get_data().tile_type

	# 4. 如果相同，无需操作
	if current_type == tile_type:
		return false

	# 5. 消耗新地块库存
	tile_inventory.consume_tile(tile_type, 1)

	# 6. 归还旧地块到库存
	tile_inventory.add_tile(current_type, 1)

	# 7. 替换地块
	grid_manager.replace_tile(cell, tile_type)

	# 8. 更新配置数组（编辑器网格坐标直接对应配置索引）
	var config_idx := cell.y * grid_width + cell.x
	if config_idx >= 0 and config_idx < _current_player_config.size():
		_current_player_config[config_idx] = tile_type

	# 9. 发送信号
	tile_selected.emit(tile_type)
	tile_placed.emit(cell, tile_type)
	config_changed.emit()

	return true


## 交换棋盘上两个地块的位置
func swap_tiles_on_board(cell_a: Vector2i, cell_b: Vector2i) -> bool:
	# 验证位置
	var grid_height: int = grid_manager.get_grid_height() if grid_manager else 4
	var grid_width: int = grid_manager.get_grid_width() if grid_manager else 7

	if cell_a.x < 0 or cell_a.x >= grid_width or cell_a.y < 0 or cell_a.y >= grid_height:
		return false
	if cell_b.x < 0 or cell_b.x >= grid_width or cell_b.y < 0 or cell_b.y >= grid_height:
		return false

	# 相同位置无需交换
	if cell_a == cell_b:
		return false

	# 获取两个地块
	var tile_a: Tile = grid_manager.get_tile(cell_a)
	var tile_b: Tile = grid_manager.get_tile(cell_b)

	if not tile_a or not tile_b or not tile_a.is_editable or not tile_b.is_editable:
		return false

	# 获取两个地块类型
	var type_a: TileConstants.TileType = tile_a.get_data().tile_type
	var type_b: TileConstants.TileType = tile_b.get_data().tile_type

	# 交换地块类型（使用 replace_tile）
	grid_manager.replace_tile(cell_a, type_b)
	grid_manager.replace_tile(cell_b, type_a)

	# 更新配置数组
	var config_idx_a := cell_a.y * grid_width + cell_a.x
	var config_idx_b := cell_b.y * grid_width + cell_b.x

	if config_idx_a >= 0 and config_idx_a < _current_player_config.size():
		_current_player_config[config_idx_a] = type_b
	if config_idx_b >= 0 and config_idx_b < _current_player_config.size():
		_current_player_config[config_idx_b] = type_a

	# 发送信号
	tile_placed.emit(cell_a, type_b)
	tile_placed.emit(cell_b, type_a)
	config_changed.emit()

	return true
