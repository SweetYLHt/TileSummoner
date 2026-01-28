## 下拉选择器组件
##
## 带标签的下拉选择器（OptionButton 包装）
@tool
extends HBoxContainer


## ============================================================================
## 信号
## ============================================================================

signal item_selected(index: int)


## ============================================================================
## 导出属性
## ============================================================================

@export var label_text: String = "Option":
	set(value):
		label_text = value
		_update_label()

@export var options: PackedStringArray = []:
	set(value):
		options = value
		_update_options()

@export var selected_index: int = 0:
	set(value):
		var max_index := maxi(0, options.size() - 1)
		var clamped := clampi(value, 0, max_index) if options.size() > 0 else 0
		if selected_index != clamped:
			selected_index = clamped
			_update_selection()
			item_selected.emit(selected_index)

@export var label_min_width: float = 120.0:
	set(value):
		label_min_width = value
		_update_label()


## ============================================================================
## 节点引用
## ============================================================================

@onready var _label: Label = $Label
@onready var _option_button: OptionButton = $OptionButton


## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	_setup_nodes()
	_apply_styles()
	_update_all()
	_connect_signals()


## ============================================================================
## 公共方法
## ============================================================================

## 获取当前选中的文本
func get_selected_text() -> String:
	if _option_button and _option_button.selected >= 0:
		return _option_button.get_item_text(_option_button.selected)
	return ""


## ============================================================================
## 私有方法
## ============================================================================

func _setup_nodes() -> void:
	if not _label:
		_label = Label.new()
		_label.name = "Label"
		add_child(_label)

	if not _option_button:
		_option_button = OptionButton.new()
		_option_button.name = "OptionButton"
		add_child(_option_button)


func _apply_styles() -> void:
	if _label:
		_label.add_theme_color_override("font_color", UIThemeConstants.TEXT_WHITE)

	if _option_button:
		# 正常状态
		var normal_style := StyleBoxFlat.new()
		normal_style.bg_color = UIThemeConstants.BG_DARK
		normal_style.corner_radius_top_left = UIThemeConstants.CORNER_RADIUS_SMALL
		normal_style.corner_radius_top_right = UIThemeConstants.CORNER_RADIUS_SMALL
		normal_style.corner_radius_bottom_left = UIThemeConstants.CORNER_RADIUS_SMALL
		normal_style.corner_radius_bottom_right = UIThemeConstants.CORNER_RADIUS_SMALL
		normal_style.border_width_left = 1
		normal_style.border_width_right = 1
		normal_style.border_width_top = 1
		normal_style.border_width_bottom = 1
		normal_style.border_color = UIThemeConstants.BORDER_SUBTLE
		normal_style.content_margin_left = UIThemeConstants.CONTENT_MARGIN_SMALL
		normal_style.content_margin_right = UIThemeConstants.CONTENT_MARGIN_SMALL
		normal_style.content_margin_top = UIThemeConstants.CONTENT_MARGIN_TINY
		normal_style.content_margin_bottom = UIThemeConstants.CONTENT_MARGIN_TINY

		# Hover 状态
		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = UIThemeConstants.BG_HOVER_LIGHT
		hover_style.corner_radius_top_left = UIThemeConstants.CORNER_RADIUS_SMALL
		hover_style.corner_radius_top_right = UIThemeConstants.CORNER_RADIUS_SMALL
		hover_style.corner_radius_bottom_left = UIThemeConstants.CORNER_RADIUS_SMALL
		hover_style.corner_radius_bottom_right = UIThemeConstants.CORNER_RADIUS_SMALL
		hover_style.border_width_left = 1
		hover_style.border_width_right = 1
		hover_style.border_width_top = 1
		hover_style.border_width_bottom = 1
		hover_style.border_color = UIThemeConstants.BORDER_LIGHT
		hover_style.content_margin_left = UIThemeConstants.CONTENT_MARGIN_SMALL
		hover_style.content_margin_right = UIThemeConstants.CONTENT_MARGIN_SMALL
		hover_style.content_margin_top = UIThemeConstants.CONTENT_MARGIN_TINY
		hover_style.content_margin_bottom = UIThemeConstants.CONTENT_MARGIN_TINY

		_option_button.add_theme_stylebox_override("normal", normal_style)
		_option_button.add_theme_stylebox_override("hover", hover_style)
		_option_button.add_theme_stylebox_override("pressed", normal_style)
		_option_button.add_theme_stylebox_override("focus", normal_style)

		_option_button.add_theme_color_override("font_color", UIThemeConstants.TEXT_WHITE)
		_option_button.add_theme_color_override("font_hover_color", UIThemeConstants.GOLD)


func _connect_signals() -> void:
	if _option_button and not _option_button.item_selected.is_connected(_on_option_button_item_selected):
		_option_button.item_selected.connect(_on_option_button_item_selected)


func _update_all() -> void:
	_update_label()
	_update_options()
	_update_selection()


func _update_label() -> void:
	if _label:
		_label.text = label_text
		_label.custom_minimum_size.x = label_min_width


func _update_options() -> void:
	if not _option_button:
		return

	_option_button.clear()
	for option in options:
		_option_button.add_item(option)

	_update_selection()


func _update_selection() -> void:
	if _option_button and options.size() > 0:
		if _option_button.selected != selected_index:
			_option_button.selected = selected_index


func _on_option_button_item_selected(index: int) -> void:
	if selected_index != index:
		selected_index = index
