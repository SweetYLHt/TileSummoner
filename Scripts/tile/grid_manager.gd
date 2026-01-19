extends Node2D
class_name GridManager

## 网格尺寸
const GRID_WIDTH: int = 7
const GRID_HEIGHT: int = 9
const CELL_SIZE: Vector2i = Vector2i(250, 204)
const CELL_OFFSET: Vector2i = Vector2i(125, 102)

## 地块场景
const TILE_SCENE = preload("res://Scenes/tile/tile.tscn")

## 2D数组存储地块实例
var _grid: Array[Array] = []


## 清空网格
func clear_grid() -> void:
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if _grid.size() > y and _grid[y].size() > x:
				if _grid[y][x] != null:
					_grid[y][x].queue_free()
	_grid.clear()


## 创建7×9网格
func create_grid(enemy_config: PackedStringArray, player_config: PackedStringArray) -> void:
	clear_grid()

	# 初始化数组
	for y in range(GRID_HEIGHT):
		_grid.append([])
		for x in range(GRID_WIDTH):
			_grid[y].append(null)

	# 敌方区域（第0-4行）
	for y in range(5):
		for x in range(GRID_WIDTH):
			var idx: int = y * GRID_WIDTH + x
			if idx < enemy_config.size():
				var tile_type: StringName = enemy_config[idx]
				_create_tile(x, y, tile_type, false)

	# 我方区域（第5-8行）
	for y in range(5, GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var idx: int = (y - 5) * GRID_WIDTH + x
			if idx < player_config.size():
				var tile_type: StringName = player_config[idx]
				_create_tile(x, y, tile_type, true)


## 创建单个地块
func _create_tile(grid_x: int, grid_y: int, tile_type: StringName, is_player: bool) -> void:
	var tile: Node = TILE_SCENE.instantiate()
	var data: Resource = tileDatabase.get_tile_data(tile_type)

	if not data:
		push_error("Failed to get tile data for type: %s" % tile_type)
		tile.queue_free()
		return

	tile.set_data(data)
	tile.grid_position = Vector2i(grid_x, grid_y)
	tile.position = _calculate_position(grid_x, grid_y)
	tile.is_editable = is_player and grid_y >= 5  # 仅我方控制区可编辑

	add_child(tile)
	_grid[grid_y][grid_x] = tile


## 计算世界坐标
func _calculate_position(x: int, y: int) -> Vector2:
	return Vector2(
		x * CELL_SIZE.x + CELL_OFFSET.x,
		y * CELL_SIZE.y + CELL_OFFSET.y
	)


## 获取地块实例
func get_tile(cell: Vector2i):
	if _is_valid_cell(cell):
		return _grid[cell.y][cell.x]
	return null


## 替换地块
func replace_tile(cell: Vector2i, new_type: StringName) -> void:
	var tile: Node = get_tile(cell)
	if not tile or not tile.is_editable:
		return

	var old_type: StringName = tile.get_data().tile_type
	var new_data: Resource = tileDatabase.get_tile_data(new_type)

	if not new_data:
		push_error("Failed to get tile data for type: %s" % new_type)
		return

	tile.set_data(new_data)
	tile.play_switch_animation()

	# TODO: 发送消息 - TileChangedMessage
	# var msg := TileChangedMessage.new()
	# msg.cell = cell
	# msg.old_type = old_type
	# msg.new_type = new_type
	# MessageServer.send_message(msg)


## 坐标验证
func _is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GRID_WIDTH and \
		   cell.y >= 0 and cell.y < GRID_HEIGHT


## 获取所有地块
func get_all_tiles():
	var tiles = []
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var tile: Node = get_tile(Vector2i(x, y))
			if tile:
				tiles.append(tile)
	return tiles
