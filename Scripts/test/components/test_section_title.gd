## SectionTitle 组件单元测试
extends GdUnitTestSuite


var _section_scene: PackedScene
var _section: Control


func before() -> void:
	_section_scene = load("res://Scenes/ui/components/section_title.tscn")


func before_test() -> void:
	if _section_scene:
		_section = auto_free(_section_scene.instantiate())
		add_child(_section)


func after_test() -> void:
	_section = null


## ============================================================================
## 属性测试
## ============================================================================

func test_default_title_text() -> void:
	if not _section:
		return
	assert_str(_section.title_text).is_equal("SECTION")


func test_set_title_text() -> void:
	if not _section:
		return
	_section.title_text = "AUDIO SETTINGS"
	assert_str(_section.title_text).is_equal("AUDIO SETTINGS")


func test_default_show_underline() -> void:
	if not _section:
		return
	assert_bool(_section.show_underline).is_true()


func test_set_show_underline_false() -> void:
	if not _section:
		return
	_section.show_underline = false
	assert_bool(_section.show_underline).is_false()


func test_default_underline_width() -> void:
	if not _section:
		return
	assert_float(_section.underline_width).is_equal(80.0)


func test_set_underline_width() -> void:
	if not _section:
		return
	_section.underline_width = 120.0
	assert_float(_section.underline_width).is_equal(120.0)


## ============================================================================
## UI 测试
## ============================================================================

func test_underline_visibility() -> void:
	if not _section:
		return

	_section.show_underline = true
	await get_tree().process_frame

	var underline := _section.get_node_or_null("VBoxContainer/Underline")
	if underline:
		assert_bool(underline.visible).is_true()


func test_underline_hidden_when_disabled() -> void:
	if not _section:
		return

	_section.show_underline = false
	await get_tree().process_frame

	var underline := _section.get_node_or_null("VBoxContainer/Underline")
	if underline:
		assert_bool(underline.visible).is_false()


func test_title_icon_null_by_default() -> void:
	if not _section:
		return
	assert_object(_section.title_icon).is_null()
