extends Node

## 缓存所有地形数据
var _tile_data_cache: Dictionary = {}

func _ready() -> void:
	_load_all_tiles()


## 加载所有地形资源
func _load_all_tiles() -> void:
	var tile_types := [
		&"grassland", &"water", &"sand",
		&"rock", &"forest", &"farmland",
		&"lava", &"swamp", &"ice"
	]

	for type in tile_types:
		var path := "res://Resources/Tiles/%s.tres" % type
		var data := load(path)

		if data and data is Resource:
			# 设置脚本来关联到 TileBlockData 类
			data.set_script(load("res://Scripts/tile/tile_block_data.gd"))
			# 加载贴图
			data.texture = _load_tile_texture(type)
			_tile_data_cache[type] = data
		else:
			push_error("Failed to load tile data: %s" % path)


## 加载地块贴图
func _load_tile_texture(tile_type: StringName) -> Texture2D:
	var texture_names := {
		&"grassland": "Tile_Grassland_01.png",
		&"water": "Tile_Water_01.png",
		&"sand": "Tile_Desert_01.png",
		&"rock": "Tile_Rock_01.png",
		&"forest": "Tile_Forest_01.png",
		&"farmland": "Tile_Farmland_01.png",
		&"lava": "Tile_Lava_01.png",
		&"swamp": "Tile_Swamp_01.png",
		&"ice": "Tile_Ice_01.png"
	}

	if not texture_names.has(tile_type):
		push_error("Unknown tile type: %s" % tile_type)
		return null

	var texture_path := "res://Assets/Sprites/Tiles/%s" % texture_names[tile_type]
	return load(texture_path) as Texture2D


## 获取地形数据
func get_tile_data(tile_type: StringName):
	return _tile_data_cache.get(tile_type)


## 获取所有地形类型
func get_all_tile_types() -> Array[StringName]:
	var result: Array[StringName] = []
	result.assign(_tile_data_cache.keys())
	return result


## 获取地形显示名称
func get_tile_display_name(tile_type: StringName) -> String:
	var data: Resource = get_tile_data(tile_type)
	if data:
		return data.display_name
	return ""


## 验证地形类型是否存在
func is_valid_tile_type(tile_type: StringName) -> bool:
	return _tile_data_cache.has(tile_type)
