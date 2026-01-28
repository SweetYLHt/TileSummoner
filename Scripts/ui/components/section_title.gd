## 分区标题组件
##
## 带下划线的分区标题，可选图标
@tool
extends VBoxContainer


## ============================================================================
## 导出属性
## ============================================================================

@export var title_text: String = "SECTION":
	set(value):
		title_text = value
		_update_title()

@export var title_icon: Texture2D = null:
	set(value):
		title_icon = value
		_update_icon()

@export var show_underline: bool = true:
	set(value):
		show_underline = value
		_update_underline_visibility()

@export var underline_width: float = 80.0:
	set(value):
		underline_width = value
		_update_underline()


## ============================================================================
## 节点引用
## ============================================================================

@onready var _title_container: HBoxContainer = $TitleContainer
@onready var _icon_rect: TextureRect = $TitleContainer/Icon
@onready var _title_label: Label = $TitleContainer/Title
@onready var _underline: ColorRect = $Underline


## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	_setup_nodes()
	_apply_styles()
	_update_all()


## ============================================================================
## 私有方法
## ============================================================================

func _setup_nodes() -> void:
	if not _title_container:
		_title_container = HBoxContainer.new()
		_title_container.name = "TitleContainer"
		add_child(_title_container)

	if not _icon_rect:
		_icon_rect = TextureRect.new()
		_icon_rect.name = "Icon"
		_title_container.add_child(_icon_rect)

	if not _title_label:
		_title_label = Label.new()
		_title_label.name = "Title"
		_title_container.add_child(_title_label)

	if not _underline:
		_underline = ColorRect.new()
		_underline.name = "Underline"
		add_child(_underline)


func _apply_styles() -> void:
	if _title_label:
		_title_label.add_theme_color_override("font_color", UIThemeConstants.GOLD)
		_title_label.add_theme_font_size_override("font_size", UIThemeConstants.FONT_SIZE_TITLE)

	if _underline:
		_underline.color = UIThemeConstants.GOLD


func _update_all() -> void:
	_update_title()
	_update_icon()
	_update_underline()
	_update_underline_visibility()


func _update_title() -> void:
	if _title_label:
		_title_label.text = title_text


func _update_icon() -> void:
	if _icon_rect:
		if title_icon:
			_icon_rect.texture = title_icon
			_icon_rect.visible = true
			_icon_rect.custom_minimum_size = Vector2(16, 16)
			_icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		else:
			_icon_rect.visible = false


func _update_underline() -> void:
	if _underline:
		_underline.custom_minimum_size = Vector2(underline_width, 2)
		_underline.size = Vector2(underline_width, 2)


func _update_underline_visibility() -> void:
	if _underline:
		_underline.visible = show_underline
