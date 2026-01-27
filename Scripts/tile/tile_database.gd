extends Node

## 缓存所有地形数据，使用 TileType 枚举作为键
var _tile_data_cache: Dictionary = {}

func _ready() -> void:
	_load_all_tiles()


## 加载所有地形资源
func _load_all_tiles() -> void:
	# 如果已经加载过，跳过
	if not _tile_data_cache.is_empty():
		return

	## 地形类型到资源文件名的映射
	var tile_file_names: Dictionary = {
		TileConstants.TileType.GRASSLAND: "grassland",
		TileConstants.TileType.WATER: "water",
		TileConstants.TileType.SAND: "sand",
		TileConstants.TileType.ROCK: "rock",
		TileConstants.TileType.FOREST: "forest",
		TileConstants.TileType.FARMLAND: "farmland",
		TileConstants.TileType.LAVA: "lava",
		TileConstants.TileType.SWAMP: "swamp",
		TileConstants.TileType.ICE: "ice",
	}

	for tile_type in tile_file_names:
		var file_name: String = tile_file_names[tile_type]
		var path := "res://Resources/Tiles/%s.tres" % file_name
		var data := load(path)

		if data and data is Resource:
			_tile_data_cache[tile_type] = data
		else:
			push_error("Failed to load tile data: %s" % path)


## 获取地形数据
func get_tile_data(tile_type: TileConstants.TileType) -> TileBlockData:
	# 懒加载：如果缓存为空，先加载数据（兼容单元测试环境）
	if _tile_data_cache.is_empty():
		_load_all_tiles()
	return _tile_data_cache.get(tile_type)


## 获取所有地形类型枚举
func get_all_tile_types() -> Array[TileConstants.TileType]:
	return TileConstants.get_all_tile_types()


## 获取地形显示名称
func get_tile_display_name(tile_type: TileConstants.TileType) -> String:
	var data: TileBlockData = get_tile_data(tile_type)
	if data:
		return data.display_name
	return TileConstants.get_tile_type_name(tile_type)


## 验证地形类型是否存在
func is_valid_tile_type(tile_type: TileConstants.TileType) -> bool:
	return _tile_data_cache.has(tile_type)
