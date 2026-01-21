extends Node2D
class_name GridManager

## 地块场景路径
const TILE_SCENE_PATH = "res://Scenes/tile/tile.tscn"

## 网格配置资源
@export var config: GridConfig

## 2D数组存储地块实例
var _grid: Array[Array] = []

## 获取网格宽度
func get_grid_width() -> int:
	return config.grid_width if config else 7


## 获取网格高度
func get_grid_height() -> int:
	return config.grid_height if config else 9


## 清空网格
func clear_grid() -> void:
	var height: int = get_grid_height()
	var width: int = get_grid_width()

	for y in range(height):
		for x in range(width):
			if _grid.size() > y and _grid[y].size() > x:
				if _grid[y][x] != null:
					_grid[y][x].queue_free()
	_grid.clear()


## 创建网格
func create_grid(enemy_tiles: Array[TileConstants.TileType], player_tiles: Array[TileConstants.TileType]) -> void:
	clear_grid()

	var height: int = get_grid_height()
	var width: int = get_grid_width()

	# 初始化数组
	for y in range(height):
		_grid.append([])
		for x in range(width):
			_grid[y].append(null)

	var enemy_rows: int = config.get_enemy_area_rows() if config else 5

	# 敌方区域
	for y in range(enemy_rows):
		for x in range(width):
			var idx: int = y * width + x
			if idx < enemy_tiles.size():
				var tile_type: TileConstants.TileType = enemy_tiles[idx]
				_create_tile(x, y, tile_type, false)

	# 我方区域
	for y in range(enemy_rows, height):
		for x in range(width):
			var idx: int = (y - enemy_rows) * width + x
			if idx < player_tiles.size():
				var tile_type: TileConstants.TileType = player_tiles[idx]
				_create_tile(x, y, tile_type, true)


## 创建单个地块
func _create_tile(grid_x: int, grid_y: int, tile_type: TileConstants.TileType, is_player: bool) -> void:
	var tile_scene = load(TILE_SCENE_PATH)
	var tile: Control = tile_scene.instantiate()

	# 先添加到场景树，确保 @onready 变量初始化
	add_child(tile)

	# 再设置数据
	var data: TileBlockData = tileDatabase.get_tile_data(tile_type)

	if not data:
		push_error("Failed to get tile data for type: %d" % tile_type)
		tile.queue_free()
		_grid[grid_y][grid_x] = null
		return

	tile.set_data(data)
	tile.grid_position = Vector2i(grid_x, grid_y)
	tile.position = _calculate_position(grid_x, grid_y)

	# 仅我方控制区可编辑
	var player_start: int = config.player_area_start if config else 5
	tile.is_editable = is_player and grid_y >= player_start

	_grid[grid_y][grid_x] = tile


## 计算世界坐标
func _calculate_position(x: int, y: int) -> Vector2:
	if config:
		return config.calculate_position(x, y)

	# 后备默认值
	var cell_size: Vector2i = Vector2i(67, 54)
	var cell_offset: Vector2i = Vector2i(34, 27)
	return Vector2(
		x * cell_size.x + cell_offset.x,
		y * cell_size.y + cell_offset.y
	)


## 获取地块实例
func get_tile(cell: Vector2i):
	if _is_valid_cell(cell):
		return _grid[cell.y][cell.x]
	return null


## 替换地块
func replace_tile(cell: Vector2i, new_type: TileConstants.TileType) -> void:
	var tile: Node = get_tile(cell)
	if not tile or not tile.is_editable:
		return

	var old_type: TileConstants.TileType = tile.get_data().tile_type
	var new_data: TileBlockData = tileDatabase.get_tile_data(new_type)

	if not new_data:
		push_error("Failed to get tile data for type: %d" % new_type)
		return

	tile.set_data(new_data)
	tile.play_switch_animation()

	# 发送消息 - TileChangedMessage
	var msg := TileChangedMessage.new()
	msg.cell = cell
	msg.old_type = old_type
	msg.new_type = new_type
	MessageServer.send_message(msg)


## 坐标验证
func _is_valid_cell(cell: Vector2i) -> bool:
	if config:
		return config.is_valid_cell(cell)

	return cell.x >= 0 and cell.x < 7 and cell.y >= 0 and cell.y < 9


## 获取所有地块
func get_all_tiles():
	var tiles = []
	var height: int = get_grid_height()
	var width: int = get_grid_width()

	for y in range(height):
		for x in range(width):
			var tile: Node = get_tile(Vector2i(x, y))
			if tile:
				tiles.append(tile)
	return tiles
