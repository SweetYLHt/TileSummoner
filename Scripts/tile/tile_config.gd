extends Resource
class_name TileConfig

## 配置名称（角色/关卡/难度）
@export var config_name: StringName = &""

## 配置类型
@export var config_type: StringName = &""  # player_default, enemy_easy, enemy_hard等

## 地形配置数组（扁平化存储）
@export var tiles: Array[StringName] = []


## 获取地块类型
func get_tile_at(index: int) -> StringName:
	if index >= 0 and index < tiles.size():
		return tiles[index]
	return &"grassland"  # 默认草地


## 获取完整配置
func get_config() -> Array[StringName]:
	return tiles.duplicate()


## 获取配置大小
func get_size() -> int:
	return tiles.size()
