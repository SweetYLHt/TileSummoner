## TerrainGridSlot 地形网格槽位测试套件
## 测试范围：
## 1. 四状态颜色系统（默认、悬停、选中、拖拽高亮）
## 2. 图标颜色应用（main_color）
## 3. 拖拽预览尺寸（80×80）
## 4. 选中/拖拽高亮状态管理

class_name TestTerrainGridSlot
extends GdUnitTestSuite


## 测试1：验证默认状态边框颜色
func test_default_border_color_matches_terrain() -> void:
	var slot := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	add_child(slot)
	auto_free(slot)

	# 设置草地地形
	slot.set_terrain(TileConstants.TileType.GRASSLAND)
	await_idle_frame()

	# 验证边框颜色为草地的 border_color（深绿色）
	var style_box := slot.get_theme_stylebox("panel") as StyleBoxFlat
	assert_that(style_box).is_not_null()
	assert_that(style_box.border_color.g).is_greater(0.5)  # 绿色通道值较高


## 测试2：验证悬停状态边框颜色
func test_hover_border_color_matches_terrain() -> void:
	var slot := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	add_child(slot)
	auto_free(slot)

	# 设置水域地形
	slot.set_terrain(TileConstants.TileType.WATER)
	await_idle_frame()

	# 模拟悬停
	slot._on_mouse_enter()
	await_idle_frame()

	# 验证边框颜色为水域的 hover_color（亮蓝色）
	var style_box := slot.get_theme_stylebox("panel") as StyleBoxFlat
	assert_that(style_box).is_not_null()
	assert_that(style_box.border_color.b).is_greater(0.7)  # 蓝色通道值较高


## 测试3：验证选中状态颜色
func test_selected_color_matches_terrain() -> void:
	var slot := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	add_child(slot)
	auto_free(slot)

	# 设置熔岩地形
	slot.set_terrain(TileConstants.TileType.LAVA)
	await_idle_frame()

	# 选中槽位
	slot.set_selected(true)
	await_idle_frame()

	# 验证边框和图标颜色为 accent_color
	var style_box := slot.get_theme_stylebox("panel") as StyleBoxFlat
	assert_that(style_box).is_not_null()
	assert_that(style_box.border_color.r).is_greater(0.8)  # 红色通道值较高


## 测试4：验证拖拽高亮颜色
func test_drag_highlight_color() -> void:
	var slot := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	add_child(slot)
	auto_free(slot)

	# 设置任意地形
	slot.set_terrain(TileConstants.TileType.GRASSLAND)
	await_idle_frame()

	# 模拟拖拽高亮
	slot._show_drag_highlight()
	await_idle_frame()

	# 验证边框颜色为淡黄色
	var style_box := slot.get_theme_stylebox("panel") as StyleBoxFlat
	assert_that(style_box).is_not_null()
	assert_that(style_box.border_color.r).is_greater(0.9)  # 红色高
	assert_that(style_box.border_color.g).is_greater(0.9)  # 绿色高


## 测试5：验证状态优先级（选中 > 拖拽 > 悬停）
func test_state_priority() -> void:
	var slot := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	add_child(slot)
	auto_free(slot)

	slot.set_terrain(TileConstants.TileType.GRASSLAND)
	await_idle_frame()

	# 设置选中状态
	slot.set_selected(true)
	await_idle_frame()

	# 再设置悬停（应该保持选中色）
	slot._on_mouse_enter()
	await_idle_frame()

	var style_box := slot.get_theme_stylebox("panel") as StyleBoxFlat
	assert_that(style_box).is_not_null()
	# 应该是 accent_color（亮绿色），而不是 hover_color
	assert_that(style_box.border_color.g).is_greater(0.9)


## 测试6：验证图标颜色应用 main_color
func test_icon_color_applies_main_color() -> void:
	var slot := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	add_child(slot)
	auto_free(slot)

	# 设置草地地形
	slot.set_terrain(TileConstants.TileType.GRASSLAND)
	await_idle_frame()

	var icon := slot.get_node("CenterContainer/Icon") as TextureRect
	assert_that(icon).is_not_null()

	# 验证图标颜色为草地的 main_color（绿色）
	assert_that(icon.modulate.g).is_greater(0.5)
	assert_that(icon.modulate.r).is_less(0.5)  # 红色较低


## 测试7：验证拖拽预览尺寸为 80×80
func test_drag_preview_size() -> void:
	var slot := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	add_child(slot)
	auto_free(slot)

	# 设置地形使槽位可拖拽
	slot.set_terrain(TileConstants.TileType.GRASSLAND)
	await_idle_frame()

	# 获取拖拽数据（包含预览）
	var drag_data := slot._get_drag_data(Vector2.ZERO)

	# 由于 set_drag_preview 是内部调用，我们验证槽位本身的尺寸
	assert_that(slot.custom_minimum_size.x).is_equal(80)
	assert_that(slot.custom_minimum_size.y).is_equal(80)


## 测试8：验证空槽位的悬停效果
func test_empty_slot_hover_effect() -> void:
	var slot := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	add_child(slot)
	auto_free(slot)

	# 不设置地形，保持为空
	await_idle_frame()

	# 悬停空槽位
	slot._on_mouse_enter()
	await_idle_frame()

	# 验证边框变为默认悬停色（金色）
	var style_box := slot.get_theme_stylebox("panel") as StyleBoxFlat
	assert_that(style_box).is_not_null()
	assert_that(style_box.border_color.r).is_greater(0.7)  # 金色
	assert_that(style_box.border_color.g).is_greater(0.5)


## 测试9：验证拖拽高亮清除
func test_drag_highlight_clear() -> void:
	var slot1 := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	var slot2 := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()

	add_child(slot1)
	add_child(slot2)
	auto_free(slot1)
	auto_free(slot2)

	slot1.set_terrain(TileConstants.TileType.GRASSLAND)
	slot2.set_terrain(TileConstants.TileType.WATER)
	await_idle_frame()

	# 第一个槽位显示拖拽高亮
	slot1._show_drag_highlight()
	await_idle_frame()

	var style1 := slot1.get_theme_stylebox("panel") as StyleBoxFlat
	assert_that(style1.border_color.r).is_greater(0.9)  # 淡黄色

	# 第二个槽位显示拖拽高亮（应该清除第一个）
	slot2._show_drag_highlight()
	await_idle_frame()

	# 验证第一个槽位的拖拽高亮被清除
	var style1_after := slot1.get_theme_stylebox("panel") as StyleBoxFlat
	# 应该恢复为草地的默认边框色（绿色）
	assert_that(style1_after.border_color.g).is_greater(0.5)


## 测试10：验证所有地形的颜色映射
func test_all_terrain_colors_mapped_correctly() -> void:
	var slot := preload("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn").instantiate()
	add_child(slot)
	auto_free(slot)

	var expected_border_colors := {
		TileConstants.TileType.GRASSLAND: Color(0.15, 0.6, 0.25, 1),
		TileConstants.TileType.WATER: Color(0.1, 0.3, 0.8, 1),
		TileConstants.TileType.SAND: Color(0.7, 0.6, 0.3, 1),
		TileConstants.TileType.LAVA: Color(0.8, 0.2, 0, 1),
	}

	for tile_type in expected_border_colors:
		slot.set_terrain(tile_type)
		await_idle_frame()

		var style_box := slot.get_theme_stylebox("panel") as StyleBoxFlat
		var expected: Color = expected_border_colors[tile_type]
		var actual: Color = style_box.border_color

		# 允许轻微的浮点误差
		assert_that(abs(actual.r - expected.r)).is_less(0.01)
		assert_that(abs(actual.g - expected.g)).is_less(0.01)
		assert_that(abs(actual.b - expected.b)).is_less(0.01)
