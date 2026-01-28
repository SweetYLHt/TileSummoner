## 带标签的滑块组件
##
## 包含标签、滑块和可选的百分比显示
@tool
extends HBoxContainer


## ============================================================================
## 信号
## ============================================================================

signal value_changed(new_value: float)


## ============================================================================
## 导出属性
## ============================================================================

@export var label_text: String = "Label":
	set(value):
		label_text = value
		_update_label()

@export var min_value: float = 0.0:
	set(value):
		min_value = value
		_update_slider_range()

@export var max_value: float = 1.0:
	set(value):
		max_value = value
		_update_slider_range()

@export var step: float = 0.01:
	set(value):
		step = value
		_update_slider_range()

@export var value: float = 0.5:
	set(new_value):
		var clamped := clampf(new_value, min_value, max_value)
		if value != clamped:
			value = clamped
			_update_slider_value()
			value_changed.emit(value)

@export var show_percentage: bool = true:
	set(new_show):
		show_percentage = new_show
		_update_percentage_visibility()

@export var label_min_width: float = 120.0:
	set(value):
		label_min_width = value
		_update_label()


## ============================================================================
## 节点引用
## ============================================================================

@onready var _label: Label = $Label
@onready var _slider: HSlider = $Slider
@onready var _percentage_label: Label = $PercentageLabel


## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	_setup_nodes()
	_apply_styles()
	_update_all()
	_connect_signals()


## ============================================================================
## 私有方法
## ============================================================================

func _setup_nodes() -> void:
	# 确保节点存在
	if not _label:
		_label = Label.new()
		_label.name = "Label"
		add_child(_label)

	if not _slider:
		_slider = HSlider.new()
		_slider.name = "Slider"
		add_child(_slider)

	if not _percentage_label:
		_percentage_label = Label.new()
		_percentage_label.name = "PercentageLabel"
		add_child(_percentage_label)


func _apply_styles() -> void:
	if not _slider:
		return

	# 应用滑块轨道样式
	var track_style := _create_slider_track_style()
	var fill_style := _create_slider_fill_style()

	_slider.add_theme_stylebox_override("slider", track_style)
	_slider.add_theme_stylebox_override("grabber_area", fill_style)
	_slider.add_theme_stylebox_override("grabber_area_highlight", fill_style)
	_slider.add_theme_icon_override("grabber", _create_grabber_texture(UIThemeConstants.GOLD))
	_slider.add_theme_icon_override("grabber_highlight", _create_grabber_texture(UIThemeConstants.GOLD_BRIGHT))

	# 标签样式
	if _label:
		_label.add_theme_color_override("font_color", UIThemeConstants.TEXT_WHITE)

	if _percentage_label:
		_percentage_label.add_theme_color_override("font_color", UIThemeConstants.GOLD)
		_percentage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_percentage_label.custom_minimum_size.x = 50


func _connect_signals() -> void:
	if _slider and not _slider.value_changed.is_connected(_on_slider_value_changed):
		_slider.value_changed.connect(_on_slider_value_changed)


func _update_all() -> void:
	_update_label()
	_update_slider_range()
	_update_slider_value()
	_update_percentage_visibility()
	_update_percentage_text()


func _update_label() -> void:
	if _label:
		_label.text = label_text
		_label.custom_minimum_size.x = label_min_width


func _update_slider_range() -> void:
	if _slider:
		_slider.min_value = min_value
		_slider.max_value = max_value
		_slider.step = step


func _update_slider_value() -> void:
	if _slider and _slider.value != value:
		_slider.value = value
	_update_percentage_text()


func _update_percentage_visibility() -> void:
	if _percentage_label:
		_percentage_label.visible = show_percentage


func _update_percentage_text() -> void:
	if _percentage_label and show_percentage:
		var percentage := int((value - min_value) / (max_value - min_value) * 100)
		_percentage_label.text = "%d%%" % percentage


func _on_slider_value_changed(new_value: float) -> void:
	if value != new_value:
		value = new_value


## ============================================================================
## 样式创建方法
## ============================================================================

func _create_slider_track_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UIThemeConstants.SLIDER_TRACK_BG

	# 无圆角
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0

	# expand_margin 让轨道有高度
	style.expand_margin_top = UIThemeConstants.SLIDER_TRACK_EXPAND
	style.expand_margin_bottom = UIThemeConstants.SLIDER_TRACK_EXPAND

	return style


func _create_slider_fill_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UIThemeConstants.SLIDER_FILL

	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0

	style.expand_margin_top = UIThemeConstants.SLIDER_TRACK_EXPAND
	style.expand_margin_bottom = UIThemeConstants.SLIDER_TRACK_EXPAND

	return style


func _create_grabber_texture(core_color: Color) -> ImageTexture:
	var glow_color := UIThemeConstants.SLIDER_GRABBER_GLOW
	var glow_padding := UIThemeConstants.GRABBER_GLOW_PADDING
	var total_w := UIThemeConstants.GRABBER_WIDTH + glow_padding * 2
	var total_h := UIThemeConstants.GRABBER_HEIGHT + glow_padding * 2

	var img := Image.create(total_w, total_h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# 外层发光
	_fill_rect(img, 0, 0, total_w, total_h, glow_color)

	# 内层核心
	_fill_rect(img, glow_padding, glow_padding,
		UIThemeConstants.GRABBER_WIDTH, UIThemeConstants.GRABBER_HEIGHT, core_color)

	return ImageTexture.create_from_image(img)


func _fill_rect(img: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	for py in range(y, y + h):
		for px in range(x, x + w):
			if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
				img.set_pixel(px, py, color)
