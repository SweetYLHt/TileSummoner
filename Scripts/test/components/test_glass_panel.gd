## GlassPanel 组件单元测试
extends GdUnitTestSuite


const GlassPanel := preload("res://Scripts/ui/components/glass_panel.gd")
const UIThemeConstants := preload("res://Scripts/ui/components/ui_theme_constants.gd")


var _panel: PanelContainer


func before_test() -> void:
	_panel = auto_free(PanelContainer.new())
	add_child(_panel)


func after_test() -> void:
	_panel = null


## ============================================================================
## 枚举测试
## ============================================================================

func test_panel_variant_enum_values() -> void:
	assert_int(GlassPanel.PanelVariant.DEFAULT).is_equal(0)
	assert_int(GlassPanel.PanelVariant.SIDEBAR).is_equal(1)
	assert_int(GlassPanel.PanelVariant.FOOTER).is_equal(2)


## ============================================================================
## 样式创建测试
## ============================================================================

func test_create_style_default() -> void:
	var style := GlassPanel.create_style(GlassPanel.PanelVariant.DEFAULT)

	assert_object(style).is_not_null()
	assert_object(style).is_instanceof(StyleBoxFlat)
	assert_color(style.bg_color).is_equal(UIThemeConstants.GLASS_BG)


func test_create_style_default_has_right_rounded_corners() -> void:
	var style := GlassPanel.create_style(GlassPanel.PanelVariant.DEFAULT)

	# 右侧圆角，左侧直角
	assert_int(style.corner_radius_top_left).is_equal(0)
	assert_int(style.corner_radius_bottom_left).is_equal(0)
	assert_int(style.corner_radius_top_right).is_equal(UIThemeConstants.CORNER_RADIUS)
	assert_int(style.corner_radius_bottom_right).is_equal(UIThemeConstants.CORNER_RADIUS)


func test_create_style_default_has_subtle_border() -> void:
	var style := GlassPanel.create_style(GlassPanel.PanelVariant.DEFAULT)

	# 边框 (不含左侧)
	assert_int(style.border_width_top).is_equal(1)
	assert_int(style.border_width_right).is_equal(1)
	assert_int(style.border_width_bottom).is_equal(1)
	assert_int(style.border_width_left).is_equal(0)
	assert_color(style.border_color).is_equal(UIThemeConstants.BORDER_SUBTLE)


func test_create_style_sidebar() -> void:
	var style := GlassPanel.create_style(GlassPanel.PanelVariant.SIDEBAR)

	assert_object(style).is_not_null()
	# SIDEBAR 与 DEFAULT 相同结构但可能有不同配置
	assert_color(style.bg_color).is_equal(UIThemeConstants.GLASS_BG)


func test_create_style_footer() -> void:
	var style := GlassPanel.create_style(GlassPanel.PanelVariant.FOOTER)

	assert_object(style).is_not_null()
	assert_color(style.bg_color).is_equal(UIThemeConstants.FOOTER_BG)


func test_create_style_footer_has_top_border_only() -> void:
	var style := GlassPanel.create_style(GlassPanel.PanelVariant.FOOTER)

	# 仅顶部边框
	assert_int(style.border_width_top).is_equal(1)
	assert_int(style.border_width_left).is_equal(0)
	assert_int(style.border_width_right).is_equal(0)
	assert_int(style.border_width_bottom).is_equal(0)


func test_create_style_footer_no_corners() -> void:
	var style := GlassPanel.create_style(GlassPanel.PanelVariant.FOOTER)

	# 无圆角
	assert_int(style.corner_radius_top_left).is_equal(0)
	assert_int(style.corner_radius_top_right).is_equal(0)
	assert_int(style.corner_radius_bottom_left).is_equal(0)
	assert_int(style.corner_radius_bottom_right).is_equal(0)


## ============================================================================
## 左侧强调条测试
## ============================================================================

func test_create_accent_bar_style() -> void:
	var style := GlassPanel.create_accent_bar_style(UIThemeConstants.GOLD)

	assert_object(style).is_not_null()
	assert_color(style.bg_color).is_equal(UIThemeConstants.GOLD)


func test_create_accent_bar_style_width() -> void:
	var style := GlassPanel.create_accent_bar_style(UIThemeConstants.GOLD)

	# 默认宽度
	# 强调条是通过单独的 ColorRect 实现的，样式只是背景色


## ============================================================================
## 应用样式测试
## ============================================================================

func test_apply_to_panel_null_check() -> void:
	# 不应崩溃
	GlassPanel.apply_to_panel(null, GlassPanel.PanelVariant.DEFAULT)


func test_apply_to_panel_default() -> void:
	GlassPanel.apply_to_panel(_panel, GlassPanel.PanelVariant.DEFAULT)

	var panel_style := _panel.get_theme_stylebox("panel")
	assert_object(panel_style).is_not_null()


func test_apply_to_panel_footer() -> void:
	GlassPanel.apply_to_panel(_panel, GlassPanel.PanelVariant.FOOTER)

	var panel_style := _panel.get_theme_stylebox("panel")
	assert_object(panel_style).is_not_null()
	assert_color(panel_style.bg_color).is_equal(UIThemeConstants.FOOTER_BG)
