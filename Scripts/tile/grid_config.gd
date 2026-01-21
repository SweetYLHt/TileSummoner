extends Resource
class_name GridConfig

## 网格配置资源
## 集中管理网格尺寸、单元格大小等参数

## 网格宽度（列数）
@export var grid_width: int = 7

## 网格高度（行数）
@export var grid_height: int = 9

## 单元格渲染尺寸（像素）
@export var cell_size: Vector2i = Vector2i(67, 54)

## 单元格偏移量（像素，用于居中对齐）
@export var cell_offset: Vector2i = Vector2i(34, 27)

## 玩家区域起始行（从0开始）
@export_range(0, 9) var player_area_start: int = 5

## 敌方区域结束行（不包含）
@export_range(0, 9) var enemy_area_end: int = 5


## ============================================================================
## 属性访问器
## ============================================================================

## 获取敌方区域行数
func get_enemy_area_rows() -> int:
	return enemy_area_end


## 获取玩家区域行数
func get_player_area_rows() -> int:
	return grid_height - player_area_start


## 获取敌方地块数量
func get_enemy_tile_count() -> int:
	return enemy_area_end * grid_width


## 获取玩家地块数量
func get_player_tile_count() -> int:
	return (grid_height - player_area_start) * grid_width


## 获取总地块数量
func get_total_tile_count() -> int:
	return grid_width * grid_height


## ============================================================================
## 坐标转换
## ============================================================================

## 计算地块的世界坐标
func calculate_position(grid_x: int, grid_y: int) -> Vector2:
	return Vector2(
		grid_x * cell_size.x + cell_offset.x,
		grid_y * cell_size.y + cell_offset.y
	)


## 验证坐标是否在网格范围内
func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_width and \
		   cell.y >= 0 and cell.y < grid_height


## 判断坐标是否在敌方区域
func is_enemy_area(cell: Vector2i) -> bool:
	return is_valid_cell(cell) and cell.y < enemy_area_end


## 判断坐标是否在玩家区域
func is_player_area(cell: Vector2i) -> bool:
	return is_valid_cell(cell) and cell.y >= player_area_start


## ============================================================================
## 区域索引计算
## ============================================================================

## 计算敌方区域的数组索引
func get_enemy_area_index(x: int, y: int) -> int:
	return y * grid_width + x


## 计算玩家区域的数组索引
func get_player_area_index(x: int, y: int) -> int:
	return (y - player_area_start) * grid_width + x


## ============================================================================
## 居中计算
## ============================================================================

## 计算地图在视口中的居中偏移量
func calculate_center_offset(viewport_size: Vector2i) -> Vector2i:
	var map_size: Vector2i = Vector2i(
		grid_width * cell_size.x,
		grid_height * cell_size.y
	)
	@warning_ignore("integer_division")
	var offset_x: int = (viewport_size.x - map_size.x) / 2
	@warning_ignore("integer_division")
	var offset_y: int = (viewport_size.y - map_size.y) / 2
	return Vector2i(offset_x, offset_y)


## 获取地图总尺寸
func get_map_size() -> Vector2i:
	return Vector2i(
		grid_width * cell_size.x,
		grid_height * cell_size.y
	)
