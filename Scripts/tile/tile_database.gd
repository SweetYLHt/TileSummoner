extends Node

## 缓存所有地形数据，使用 TileType 枚举作为键
var _tile_data_cache: Dictionary = {}

func _ready() -> void:
	_load_all_tiles()


## 加载所有地形资源
func _load_all_tiles() -> void:
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
			# 设置脚本来关联到 TileBlockData 类
			data.set_script(load("res://Scripts/tile/tile_block_data.gd"))
			# 加载贴图（使用 80x80 的 _02 版本）
			data.texture = _load_tile_texture(tile_type)
			_tile_data_cache[tile_type] = data
		else:
			push_error("Failed to load tile data: %s" % path)


## 加载地块贴图（使用 80×80 的 _02 版本图片）
func _load_tile_texture(tile_type: TileConstants.TileType) -> Texture2D:
	var texture_names: Dictionary = {
		TileConstants.TileType.GRASSLAND: "Tile_Grassland_02.png",
		TileConstants.TileType.WATER: "Tile_Water_02.png",
		TileConstants.TileType.SAND: "Tile_Desert_02.png",
		TileConstants.TileType.ROCK: "Tile_Rock_02.png",
		TileConstants.TileType.FOREST: "Tile_Forest_02.png",
		TileConstants.TileType.FARMLAND: "Tile_Farmland_02.png",
		TileConstants.TileType.LAVA: "Tile_Lava_02.png",
		TileConstants.TileType.SWAMP: "Tile_Swamp_02.png",
		TileConstants.TileType.ICE: "Tile_Ice_02.png",
	}

	if not texture_names.has(tile_type):
		push_error("Unknown tile type: %d" % tile_type)
		return null

	var texture_path := "res://Assets/Sprites/Tiles/%s" % texture_names[tile_type]
	return load(texture_path) as Texture2D


## 获取地形数据
func get_tile_data(tile_type: TileConstants.TileType) -> TileBlockData:
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
