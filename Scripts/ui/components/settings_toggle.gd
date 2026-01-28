## 设置开关组件
##
## 带标签的切换开关（CheckButton 包装）
@tool
extends HBoxContainer


## ============================================================================
## 信号
## ============================================================================

signal toggled(pressed: bool)


## ============================================================================
## 导出属性
## ============================================================================

@export var label_text: String = "Setting":
	set(value):
		label_text = value
		_update_label()

@export var is_on: bool = false:
	set(value):
		if is_on != value:
			is_on = value
			_update_toggle()
			toggled.emit(is_on)

@export var label_min_width: float = 120.0:
	set(value):
		label_min_width = value
		_update_label()


## ============================================================================
## 节点引用
## ============================================================================

@onready var _label: Label = $Label
@onready var _check_button: CheckButton = $CheckButton


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
	if not _label:
		_label = Label.new()
		_label.name = "Label"
		add_child(_label)

	if not _check_button:
		_check_button = CheckButton.new()
		_check_button.name = "CheckButton"
		add_child(_check_button)


func _apply_styles() -> void:
	if _label:
		_label.add_theme_color_override("font_color", UIThemeConstants.TEXT_WHITE)

	if _check_button:
		# CheckButton 的样式通过 add_theme_stylebox_override 设置
		# 开启状态
		var on_style := StyleBoxFlat.new()
		on_style.bg_color = UIThemeConstants.TOGGLE_ON_BG
		on_style.corner_radius_top_left = 12
		on_style.corner_radius_top_right = 12
		on_style.corner_radius_bottom_left = 12
		on_style.corner_radius_bottom_right = 12

		# 关闭状态
		var off_style := StyleBoxFlat.new()
		off_style.bg_color = UIThemeConstants.TOGGLE_OFF_BG
		off_style.corner_radius_top_left = 12
		off_style.corner_radius_top_right = 12
		off_style.corner_radius_bottom_left = 12
		off_style.corner_radius_bottom_right = 12


func _connect_signals() -> void:
	if _check_button and not _check_button.toggled.is_connected(_on_check_button_toggled):
		_check_button.toggled.connect(_on_check_button_toggled)


func _update_all() -> void:
	_update_label()
	_update_toggle()


func _update_label() -> void:
	if _label:
		_label.text = label_text
		_label.custom_minimum_size.x = label_min_width


func _update_toggle() -> void:
	if _check_button and _check_button.button_pressed != is_on:
		_check_button.button_pressed = is_on


func _on_check_button_toggled(pressed: bool) -> void:
	if is_on != pressed:
		is_on = pressed
