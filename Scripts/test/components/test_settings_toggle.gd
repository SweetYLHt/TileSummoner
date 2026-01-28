## SettingsToggle 组件单元测试
extends GdUnitTestSuite


var _toggle_scene: PackedScene
var _toggle: Control


func before() -> void:
	_toggle_scene = load("res://Scenes/ui/components/settings_toggle.tscn")


func before_test() -> void:
	if _toggle_scene:
		_toggle = auto_free(_toggle_scene.instantiate())
		add_child(_toggle)


func after_test() -> void:
	_toggle = null


## ============================================================================
## 属性测试
## ============================================================================

func test_default_label_text() -> void:
	if not _toggle:
		return
	assert_str(_toggle.label_text).is_equal("Setting")


func test_set_label_text() -> void:
	if not _toggle:
		return
	_toggle.label_text = "Enable Sound"
	assert_str(_toggle.label_text).is_equal("Enable Sound")


func test_default_is_on() -> void:
	if not _toggle:
		return
	assert_bool(_toggle.is_on).is_false()


func test_set_is_on_true() -> void:
	if not _toggle:
		return
	_toggle.is_on = true
	assert_bool(_toggle.is_on).is_true()


func test_set_is_on_false() -> void:
	if not _toggle:
		return
	_toggle.is_on = true
	_toggle.is_on = false
	assert_bool(_toggle.is_on).is_false()


## ============================================================================
## 信号测试
## ============================================================================

func test_toggled_signal_emitted() -> void:
	if not _toggle:
		return

	var signal_monitor := monitor_signals(_toggle)

	_toggle.is_on = true

	await get_tree().process_frame
	assert_signal(signal_monitor).is_emitted("toggled")


## ============================================================================
## UI 测试
## ============================================================================

func test_label_min_width() -> void:
	if not _toggle:
		return

	_toggle.label_min_width = 150.0

	await get_tree().process_frame

	var label := _toggle.get_node_or_null("Label")
	if label:
		assert_float(label.custom_minimum_size.x).is_equal(150.0)
