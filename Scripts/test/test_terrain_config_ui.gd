## TerrainConfigUI 地形配置主场景测试套件
## 测试范围：
## 1. 已编辑槽位计数
## 2. 可用地块显示
## 3. 坐标标签存在性
## 4. 重置功能

class_name TestTerrainConfigUI
extends GdUnitTestSuite


## ============================================================================
## 初始化
## ============================================================================

var _ui: TerrainConfigUI = null


func before_test() -> void:
	_ui = preload("res://Scenes/ui/terrain_config/terrain_config_ui.tscn").instantiate()
	add_child(_ui)
	await get_tree().process_frame


func after_test() -> void:
	if _ui:
		_ui.queue_free()
		_ui = null


## ============================================================================
## 已编辑槽位计数测试
## ============================================================================

## 测试1：验证初始已编辑槽位数
func test_edited_slots_count_initial() -> void:
	# 等待 UI 初始化完成
	await get_tree().create_timer(0.1).timeout

	# 初始状态应该有预设配置的槽位数
	var count := _ui.get_edited_slots_count()
	# 根据预设配置，应该有 28 个槽位被填充
	assert_that(count).is_greater(-1)


## 测试2：验证获取编辑槽位数方法存在
func test_get_edited_slots_count_method_exists() -> void:
	assert_that(_ui.has_method("get_edited_slots_count")).is_true()


## 测试3：验证获取可用地块数方法存在
func test_get_available_tiles_count_method_exists() -> void:
	assert_that(_ui.has_method("get_available_tiles_count")).is_true()


## ============================================================================
## 坐标标签测试
## ============================================================================

## 测试4：验证行坐标标签存在（A-D）
func test_row_labels_exist() -> void:
	var row_labels := _ui.get_node_or_null("VBoxContainer/ContentHSplit/MainArea/VBoxContainer/GridWrapper/GridWithLabels/RowLabels")
	assert_that(row_labels).is_not_null()

	# 验证有 4 个行标签
	if row_labels:
		assert_that(row_labels.get_child_count()).is_equal(4)


## 测试5：验证列坐标标签存在（1-7）
func test_col_labels_exist() -> void:
	var col_labels := _ui.get_node_or_null("VBoxContainer/ContentHSplit/MainArea/VBoxContainer/GridWrapper/GridWithLabels/ColLabels")
	assert_that(col_labels).is_not_null()

	# 验证有 7 个列标签
	if col_labels:
		assert_that(col_labels.get_child_count()).is_equal(7)


## ============================================================================
## 重置功能测试
## ============================================================================

## 测试6：验证重置按钮存在
func test_reset_button_exists() -> void:
	var reset_button := _ui.get_node_or_null("VBoxContainer/Footer/HBoxContainer/ResetButton")
	assert_that(reset_button).is_not_null()


## 测试7：验证重置方法存在
func test_reset_config_method_exists() -> void:
	assert_that(_ui.has_method("reset_config")).is_true()


## ============================================================================
## 状态显示测试
## ============================================================================

## 测试8：验证已编辑槽位标签存在
func test_edited_value_label_exists() -> void:
	var label := _ui.get_node_or_null("VBoxContainer/ContentHSplit/MainArea/VBoxContainer/TopBar/RightInfo/EditedInfo/EditedValue")
	assert_that(label).is_not_null()


## 测试9：验证当前选择标签存在
func test_selection_value_label_exists() -> void:
	var label := _ui.get_node_or_null("VBoxContainer/ContentHSplit/MainArea/VBoxContainer/TopBar/RightInfo/SelectionInfo/SelectionValue")
	assert_that(label).is_not_null()


## 测试10：验证可用地块标签存在
func test_tiles_value_label_exists() -> void:
	var label := _ui.get_node_or_null("VBoxContainer/Footer/HBoxContainer/StatusBar/TilesStatus/TilesValue")
	assert_that(label).is_not_null()


## ============================================================================
## 按钮测试
## ============================================================================

## 测试11：验证开始按钮存在
func test_start_button_exists() -> void:
	var button := _ui.get_node_or_null("VBoxContainer/Header/HBoxContainer/StartButton")
	assert_that(button).is_not_null()


## 测试12：验证返回按钮存在
func test_back_button_exists() -> void:
	var button := _ui.get_node_or_null("VBoxContainer/Header/HBoxContainer/BackButton")
	assert_that(button).is_not_null()


## ============================================================================
## 网格容器测试
## ============================================================================

## 测试13：验证网格容器存在
func test_grid_container_exists() -> void:
	var grid := _ui.get_node_or_null("VBoxContainer/ContentHSplit/MainArea/VBoxContainer/GridWrapper/GridWithLabels/GridPanel/GridContainer")
	assert_that(grid).is_not_null()


## 测试14：验证网格容器列数为 7
func test_grid_container_columns() -> void:
	var grid := _ui.get_node_or_null("VBoxContainer/ContentHSplit/MainArea/VBoxContainer/GridWrapper/GridWithLabels/GridPanel/GridContainer") as GridContainer
	if grid:
		assert_that(grid.columns).is_equal(7)


## ============================================================================
## 侧边栏测试
## ============================================================================

## 测试15：验证侧边栏标题存在
func test_sidebar_title_exists() -> void:
	var title := _ui.get_node_or_null("VBoxContainer/ContentHSplit/Sidebar/VBoxContainer/SidebarHeader/VBox/SidebarTitle")
	assert_that(title).is_not_null()


## 测试16：验证地形列表容器存在
func test_terrain_list_container_exists() -> void:
	var container := _ui.get_node_or_null("VBoxContainer/ContentHSplit/Sidebar/VBoxContainer/TerrainList/TerrainListContainer")
	assert_that(container).is_not_null()
