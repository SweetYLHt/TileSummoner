extends Resource
class_name TileConfig

## 配置名称（角色/关卡/难度）
@export var config_name: String = ""

## 配置类型（枚举值，.tres 中存储为整数）
## 0=PLAYER_DEFAULT, 1=ENEMY_EASY, 2=ENEMY_MEDIUM, 3=ENEMY_HARD
@export var config_type: TileConstants.ConfigType = TileConstants.ConfigType.PLAYER_DEFAULT

## 敌方区域配置（5行 × 7列 = 35个）
## 存储 TileType 枚举值（在 .tres 中显示为整数数组）
@export var enemy_tiles: Array[TileConstants.TileType] = []

## 玩家区域配置（4行 × 7列 = 28个）
## 存储 TileType 枚举值（在 .tres 中显示为整数数组）
@export var player_tiles: Array[TileConstants.TileType] = []


## ============================================================================
## 敌方区域
## ============================================================================

## 获取敌方区域配置
func get_enemy_tiles() -> Array[TileConstants.TileType]:
	return enemy_tiles.duplicate()


## 获取敌方区域指定位置的地块类型
func get_enemy_tile_at(index: int) -> TileConstants.TileType:
	if index >= 0 and index < enemy_tiles.size():
		return enemy_tiles[index]
	return TileConstants.TileType.GRASSLAND


## 设置敌方区域配置
func set_enemy_tiles(tiles: Array[TileConstants.TileType]) -> void:
	enemy_tiles = tiles.duplicate()


## ============================================================================
## 玩家区域
## ============================================================================

## 获取玩家区域配置
func get_player_tiles() -> Array[TileConstants.TileType]:
	return player_tiles.duplicate()


## 获取玩家区域指定位置的地块类型
func get_player_tile_at(index: int) -> TileConstants.TileType:
	if index >= 0 and index < player_tiles.size():
		return player_tiles[index]
	return TileConstants.TileType.GRASSLAND


## 设置玩家区域配置
func set_player_tiles(tiles: Array[TileConstants.TileType]) -> void:
	player_tiles = tiles.duplicate()


## ============================================================================
## 合并接口
## ============================================================================

## 获取完整配置（合并敌我双方）
func get_all_tiles() -> Array[TileConstants.TileType]:
	var result: Array[TileConstants.TileType] = []
	result.append_array(enemy_tiles)
	result.append_array(player_tiles)
	return result


## 获取配置大小（总地块数）
func get_size() -> int:
	return enemy_tiles.size() + player_tiles.size()


## 获取地块类型（通用索引访问）
func get_tile_at(index: int) -> TileConstants.TileType:
	var enemy_count: int = enemy_tiles.size()
	if index < enemy_count:
		return get_enemy_tile_at(index)
	return get_player_tile_at(index - enemy_count)
