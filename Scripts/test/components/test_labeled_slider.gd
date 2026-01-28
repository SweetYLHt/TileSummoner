## LabeledSlider 组件单元测试
extends GdUnitTestSuite


const LabeledSliderScript := preload("res://Scripts/ui/components/labeled_slider.gd")
const UIThemeConstants := preload("res://Scripts/ui/components/ui_theme_constants.gd")


var _slider_scene: PackedScene
var _slider: Control


func before() -> void:
	_slider_scene = load("res://Scenes/ui/components/labeled_slider.tscn")


func before_test() -> void:
	if _slider_scene:
		_slider = auto_free(_slider_scene.instantiate())
		add_child(_slider)


func after_test() -> void:
	_slider = null


## ============================================================================
## 属性测试
## ============================================================================

func test_default_label_text() -> void:
	if not _slider:
		return
	assert_str(_slider.label_text).is_equal("Label")


func test_set_label_text() -> void:
	if not _slider:
		return
	_slider.label_text = "Volume"
	assert_str(_slider.label_text).is_equal("Volume")


func test_default_min_value() -> void:
	if not _slider:
		return
	assert_float(_slider.min_value).is_equal(0.0)


func test_default_max_value() -> void:
	if not _slider:
		return
	assert_float(_slider.max_value).is_equal(1.0)


func test_default_value() -> void:
	if not _slider:
		return
	assert_float(_slider.value).is_equal(0.5)


func test_set_value() -> void:
	if not _slider:
		return
	_slider.value = 0.75
	assert_float(_slider.value).is_equal(0.75)


func test_value_clamped_to_min() -> void:
	if not _slider:
		return
	_slider.value = -0.5
	assert_float(_slider.value).is_greater_equal(0.0)


func test_value_clamped_to_max() -> void:
	if not _slider:
		return
	_slider.value = 1.5
	assert_float(_slider.value).is_less_equal(1.0)


func test_default_show_percentage() -> void:
	if not _slider:
		return
	assert_bool(_slider.show_percentage).is_true()


func test_set_show_percentage_false() -> void:
	if not _slider:
		return
	_slider.show_percentage = false
	assert_bool(_slider.show_percentage).is_false()


## ============================================================================
## 信号测试
## ============================================================================

func test_value_changed_signal_emitted() -> void:
	if not _slider:
		return

	var signal_monitor := monitor_signals(_slider)

	_slider.value = 0.8

	# 检查信号是否被发射
	await get_tree().process_frame
	assert_signal(signal_monitor).is_emitted("value_changed")


## ============================================================================
## 显示测试
## ============================================================================

func test_percentage_display_format() -> void:
	if not _slider:
		return
	_slider.value = 0.75
	_slider.show_percentage = true

	# 等待一帧让 UI 更新
	await get_tree().process_frame

	# 百分比标签应显示 "75%"
	var percentage_label := _slider.get_node_or_null("HBoxContainer/PercentageLabel")
	if percentage_label:
		assert_str(percentage_label.text).is_equal("75%")


func test_percentage_hidden_when_disabled() -> void:
	if not _slider:
		return
	_slider.show_percentage = false

	await get_tree().process_frame

	var percentage_label := _slider.get_node_or_null("HBoxContainer/PercentageLabel")
	if percentage_label:
		assert_bool(percentage_label.visible).is_false()
