## DropdownSelect 组件单元测试
extends GdUnitTestSuite


var _dropdown_scene: PackedScene
var _dropdown: Control


func before() -> void:
	_dropdown_scene = load("res://Scenes/ui/components/dropdown_select.tscn")


func before_test() -> void:
	if _dropdown_scene:
		_dropdown = auto_free(_dropdown_scene.instantiate())
		add_child(_dropdown)


func after_test() -> void:
	_dropdown = null


## ============================================================================
## 属性测试
## ============================================================================

func test_default_label_text() -> void:
	if not _dropdown:
		return
	assert_str(_dropdown.label_text).is_equal("Option")


func test_set_label_text() -> void:
	if not _dropdown:
		return
	_dropdown.label_text = "Resolution"
	assert_str(_dropdown.label_text).is_equal("Resolution")


func test_default_options_empty() -> void:
	if not _dropdown:
		return
	assert_int(_dropdown.options.size()).is_equal(0)


func test_set_options() -> void:
	if not _dropdown:
		return
	_dropdown.options = PackedStringArray(["Low", "Medium", "High"])
	assert_int(_dropdown.options.size()).is_equal(3)


func test_default_selected_index() -> void:
	if not _dropdown:
		return
	assert_int(_dropdown.selected_index).is_equal(0)


func test_set_selected_index() -> void:
	if not _dropdown:
		return
	_dropdown.options = PackedStringArray(["A", "B", "C"])
	_dropdown.selected_index = 2
	assert_int(_dropdown.selected_index).is_equal(2)


func test_selected_index_clamped() -> void:
	if not _dropdown:
		return
	_dropdown.options = PackedStringArray(["A", "B"])
	_dropdown.selected_index = 10
	# 应该被限制在有效范围内
	assert_int(_dropdown.selected_index).is_less_equal(1)


## ============================================================================
## 信号测试
## ============================================================================

func test_item_selected_signal_emitted() -> void:
	if not _dropdown:
		return

	_dropdown.options = PackedStringArray(["A", "B", "C"])
	await get_tree().process_frame

	var signal_monitor := monitor_signals(_dropdown)

	_dropdown.selected_index = 1

	await get_tree().process_frame
	assert_signal(signal_monitor).is_emitted("item_selected")


## ============================================================================
## UI 测试
## ============================================================================

func test_option_button_populated() -> void:
	if not _dropdown:
		return

	_dropdown.options = PackedStringArray(["Option A", "Option B"])
	await get_tree().process_frame

	var option_button := _dropdown.get_node_or_null("OptionButton")
	if option_button:
		assert_int(option_button.item_count).is_equal(2)
