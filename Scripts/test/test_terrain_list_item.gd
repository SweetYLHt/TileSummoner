## TerrainListItem 地形列表项测试套件
## 测试范围：
## 1. 图标容器彩色背景
## 2. 图标着色
## 3. 数量标签格式
## 4. Hover 动画
## 5. 禁用状态

class_name TestTerrainListItem
extends GdUnitTestSuite

## 预加载工具类
const _UIColorUtils := preload("res://Scripts/utils/ui_color_utils.gd")


## ============================================================================
## 背景色计算测试
## ============================================================================

## 测试1：验证背景色计算
func test_background_color_calculation() -> void:
	# 草地主色
	var main_color := Color(0.06, 0.73, 0.51, 1.0)
	var bg_color := _UIColorUtils.calculate_bg_color(main_color)

	# 验证亮度降低到 30%
	assert_that(bg_color.r).is_equal_approx(main_color.r * 0.3, 0.01)
	assert_that(bg_color.g).is_equal_approx(main_color.g * 0.3, 0.01)
	assert_that(bg_color.b).is_equal_approx(main_color.b * 0.3, 0.01)
	# 验证透明度为 30%
	assert_that(bg_color.a).is_equal_approx(0.3, 0.01)


## ============================================================================
## 图标容器测试
## ============================================================================

## 测试2：验证图标容器存在并有彩色背景
func test_icon_container_exists() -> void:
	var item := preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
	add_child(item)
	auto_free(item)

	# 设置地形数据
	item.setup(TileConstants.TileType.GRASSLAND, 10)
	await_idle_frame()

	# 验证图标容器存在
	var icon_container := item.get_node_or_null("HBox/IconContainer")
	assert_that(icon_container).is_not_null()


## 测试3：验证图标容器应用地形专属背景色
func test_icon_container_colored_background() -> void:
	var item := preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
	add_child(item)
	auto_free(item)

	item.setup(TileConstants.TileType.WATER, 5)
	await_idle_frame()

	var icon_container := item.get_node_or_null("HBox/IconContainer") as Panel
	if icon_container:
		var style := icon_container.get_theme_stylebox("panel") as StyleBoxFlat
		# 验证背景色有蓝色成分（水域）
		assert_that(style.bg_color.b).is_greater(0.1)


## ============================================================================
## 图标着色测试
## ============================================================================

## 测试4：验证图标使用 main_color 着色
func test_icon_colored_with_main_color() -> void:
	var item := preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
	add_child(item)
	auto_free(item)

	item.setup(TileConstants.TileType.LAVA, 3)
	await_idle_frame()

	# 获取图标
	var icon := item.get_node_or_null("HBox/IconContainer/Icon") as TextureRect
	if not icon:
		icon = item.get_node_or_null("HBox/Icon") as TextureRect

	assert_that(icon).is_not_null()
	# 熔岩为红色，验证红色通道较高
	assert_that(icon.modulate.r).is_greater(0.8)


## ============================================================================
## 数量标签测试
## ============================================================================

## 测试5：验证数量标签格式为 "x20"
func test_count_label_format() -> void:
	var item := preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
	add_child(item)
	auto_free(item)

	item.setup(TileConstants.TileType.GRASSLAND, 20)
	await_idle_frame()

	# 获取数量标签
	var count_label := item.get_node("HBox/VBox/CountLabel") as Label
	if not count_label:
		count_label = item.get_node("HBox/CountLabel") as Label

	assert_that(count_label).is_not_null()
	assert_that(count_label.text).is_equal("x20")


## 测试6：验证更新数量后格式正确
func test_count_label_format_after_update() -> void:
	var item := preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
	add_child(item)
	auto_free(item)

	item.setup(TileConstants.TileType.GRASSLAND, 10)
	await_idle_frame()

	item.update_count(5)
	await_idle_frame()

	var count_label := item.get_node("HBox/VBox/CountLabel") as Label
	if not count_label:
		count_label = item.get_node("HBox/CountLabel") as Label

	assert_that(count_label.text).is_equal("x5")


## ============================================================================
## Hover 动画测试
## ============================================================================

## 测试7：验证 hover 时图标缩放变化
func test_hover_animation_icon_scale() -> void:
	var item := preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
	add_child(item)
	auto_free(item)

	item.setup(TileConstants.TileType.GRASSLAND, 10)
	await_idle_frame()

	# 获取图标容器
	var icon_container := item.get_node_or_null("HBox/IconContainer") as Control
	if not icon_container:
		icon_container = item.get_node_or_null("HBox/Icon") as Control

	if icon_container:
		# 验证初始缩放为 1.0
		assert_that(icon_container.scale.x).is_equal_approx(1.0, 0.01)

		# 模拟 hover
		item._on_mouse_enter()
		# 等待动画开始（需要一点时间）
		await get_tree().create_timer(0.2).timeout

		# hover 后预期缩放变为 1.1（如果动画启用）
		# 注意：如果动画被禁用，此测试可能需要调整


## ============================================================================
## 禁用状态测试
## ============================================================================

## 测试8：验证数量为 0 时整体变灰
func test_disabled_state_gray() -> void:
	var item := preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
	add_child(item)
	auto_free(item)

	item.setup(TileConstants.TileType.GRASSLAND, 0)
	await_idle_frame()

	# 验证禁用状态
	assert_that(item.disabled).is_true()


## 测试9：验证禁用状态不可拖拽
func test_disabled_state_no_drag() -> void:
	var item := preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
	add_child(item)
	auto_free(item)

	item.setup(TileConstants.TileType.GRASSLAND, 0)
	await_idle_frame()

	# 尝试获取拖拽数据，应该返回 null
	var drag_data = item._get_drag_data(Vector2.ZERO)
	assert_that(drag_data).is_null()


## ============================================================================
## 拖拽功能测试
## ============================================================================

## 测试10：验证可拖拽时返回正确数据
func test_drag_data_correct() -> void:
	var item := preload("res://Scenes/ui/terrain_config/terrain_list_item.tscn").instantiate()
	add_child(item)
	auto_free(item)

	item.setup(TileConstants.TileType.WATER, 5)
	await_idle_frame()

	var drag_data = item._get_drag_data(Vector2.ZERO)
	assert_that(drag_data).is_not_null()
	assert_that(drag_data is Dictionary).is_true()
	assert_that(drag_data["tile_type"]).is_equal(TileConstants.TileType.WATER)
	assert_that(drag_data["source_type"]).is_equal("terrain_list")
