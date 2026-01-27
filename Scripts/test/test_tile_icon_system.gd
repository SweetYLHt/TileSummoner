class_name TestTileIconSystem
extends GdUnitTestSuite

## Tile地块边框+图标系统测试套件
## 测试范围：
## 1. 节点结构验证（BorderLayer + IconLayer）
## 2. 图标加载和映射验证
## 3. 地形颜色系统验证
## 4. 交互状态颜色变化验证


## 测试1：验证Tile有IconLayer子节点
func test_tile_has_icon_layer() -> void:
	var tile := preload("res://Scenes/tile/tile.tscn").instantiate()
	add_child(tile)
	auto_free(tile)

	assert_that(tile.get_node_or_null("IconLayer")).is_not_null()
	assert_that(tile.get_node("IconLayer")).is_instanceof(TextureRect)


## 测试2：验证Tile有BorderLayer子节点
func test_tile_has_border_layer() -> void:
	var tile := preload("res://Scenes/tile/tile.tscn").instantiate()
	add_child(tile)
	auto_free(tile)

	assert_that(tile.get_node_or_null("BorderLayer")).is_not_null()
	assert_that(tile.get_node("BorderLayer")).is_instanceof(Panel)


## 测试3：验证图标正确加载（草地地形）
func test_tile_loads_correct_icon() -> void:
	var tile := preload("res://Scenes/tile/tile.tscn").instantiate()
	add_child(tile)
	auto_free(tile)

	var grass_data := tileDatabase.get_tile_data(TileConstants.TileType.GRASSLAND)
	tile.set_data(grass_data)
	await_idle_frame()

	var icon_layer := tile.get_node("IconLayer") as TextureRect
	assert_that(icon_layer.texture).is_not_null()

	var texture_path := str(icon_layer.texture.resource_path)
	assert_that(texture_path).contains("grass.svg")


## 测试4：验证所有地形图标映射正确
func test_all_tile_types_have_correct_icons() -> void:
	var tile := preload("res://Scenes/tile/tile.tscn").instantiate()
	add_child(tile)
	auto_free(tile)

	var icon_mapping := {
		TileConstants.TileType.GRASSLAND: "grass.svg",
		TileConstants.TileType.WATER: "water_drop.svg",
		TileConstants.TileType.SAND: "sand.svg",
		TileConstants.TileType.ROCK: "rock.svg",
		TileConstants.TileType.FOREST: "forest.svg",
		TileConstants.TileType.FARMLAND: "agriculture.svg",
		TileConstants.TileType.LAVA: "volcano.svg",
		TileConstants.TileType.SWAMP: "blur_on.svg",
		TileConstants.TileType.ICE: "ac_unit.svg",
	}

	for tile_type in icon_mapping:
		var data := tileDatabase.get_tile_data(tile_type)
		tile.set_data(data)
		await_idle_frame()

		var icon_layer := tile.get_node("IconLayer") as TextureRect
		var texture_path := str(icon_layer.texture.resource_path)
		assert_that(texture_path).contains(icon_mapping[tile_type])


## 测试5：验证边框颜色正确应用（水域蓝色边框）
func test_tile_border_color_matches_terrain() -> void:
	var tile := preload("res://Scenes/tile/tile.tscn").instantiate()
	add_child(tile)
	auto_free(tile)

	var water_data := tileDatabase.get_tile_data(TileConstants.TileType.WATER)
	tile.set_data(water_data)
	await_idle_frame()

	var border_layer := tile.get_node("BorderLayer") as Panel
	var style_box := border_layer.get_theme_stylebox("panel")
	assert_that(style_box).is_instanceof(StyleBoxFlat)

	var border_color := (style_box as StyleBoxFlat).border_color
	# 验证边框颜色偏蓝色（蓝色通道值较高）
	assert_that(border_color.b).is_greater(0.5)


## 测试6：验证图标颜色正确应用（草地绿色图标）
func test_tile_icon_color_matches_terrain() -> void:
	var tile := preload("res://Scenes/tile/tile.tscn").instantiate()
	add_child(tile)
	auto_free(tile)

	var grass_data := tileDatabase.get_tile_data(TileConstants.TileType.GRASSLAND)
	tile.set_data(grass_data)
	await_idle_frame()

	var icon_layer := tile.get_node("IconLayer") as TextureRect
	var icon_color := icon_layer.modulate

	# 验证图标颜色偏绿色（绿色通道值较高）
	assert_that(icon_color.g).is_greater(0.5)


## 测试7：验证悬停状态颜色变化
func test_tile_hover_color_change() -> void:
	var tile := preload("res://Scenes/tile/tile.tscn").instantiate()
	add_child(tile)
	tile.is_editable = true # 允许悬停交互
	auto_free(tile)

	var water_data := tileDatabase.get_tile_data(TileConstants.TileType.WATER)
	tile.set_data(water_data)
	await_idle_frame()

	# 模拟悬停
	tile.set_hover(true)
	await_idle_frame()

	var border_layer := tile.get_node("BorderLayer") as Panel
	var style_box := border_layer.get_theme_stylebox("panel") as StyleBoxFlat
	var hover_color := style_box.border_color

	# 悬停时颜色应该更亮
	assert_that(hover_color.b).is_greater(0.7)


## 测试8：验证选中状态颜色变化
func test_tile_selected_color_change() -> void:
	var tile := preload("res://Scenes/tile/tile.tscn").instantiate()
	add_child(tile)
	auto_free(tile)

	var lava_data := tileDatabase.get_tile_data(TileConstants.TileType.LAVA)
	tile.set_data(lava_data)
	await_idle_frame()

	# 选中地块
	tile.highlight()
	await_idle_frame()

	var border_layer := tile.get_node("BorderLayer") as Panel
	var style_box := border_layer.get_theme_stylebox("panel") as StyleBoxFlat
	var selected_color := style_box.border_color

	# 选中时应该使用强调色（更亮的红色）
	assert_that(selected_color.r).is_greater(0.8)


## 测试9：验证所有地形颜色配置正确
func test_all_terrain_colors_configured() -> void:
	var tile := preload("res://Scenes/tile/tile.tscn").instantiate()
	add_child(tile)
	auto_free(tile)

	var expected_colors := {
		TileConstants.TileType.GRASSLAND: Color(0.2, 0.8, 0.3),
		TileConstants.TileType.WATER: Color(0.2, 0.5, 1.0),
		TileConstants.TileType.SAND: Color(0.9, 0.8, 0.5),
		TileConstants.TileType.ROCK: Color(0.5, 0.5, 0.5),
		TileConstants.TileType.FOREST: Color(0.1, 0.5, 0.2),
		TileConstants.TileType.FARMLAND: Color(0.8, 0.7, 0.3),
		TileConstants.TileType.LAVA: Color(1.0, 0.4, 0.1),
		TileConstants.TileType.SWAMP: Color(0.4, 0.5, 0.3),
		TileConstants.TileType.ICE: Color(0.7, 0.9, 1.0),
	}

	for tile_type in expected_colors:
		var data := tileDatabase.get_tile_data(tile_type)
		tile.set_data(data)
		await_idle_frame()

		var icon_layer := tile.get_node("IconLayer") as TextureRect
		var actual_color := icon_layer.modulate
		var expected: Color = expected_colors[tile_type]

		# 允许轻微的浮点误差
		assert_that(abs(actual_color.r - expected.r)).is_less(0.01)
		assert_that(abs(actual_color.g - expected.g)).is_less(0.01)
		assert_that(abs(actual_color.b - expected.b)).is_less(0.01)
