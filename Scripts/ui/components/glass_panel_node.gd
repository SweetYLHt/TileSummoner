## 玻璃面板节点脚本
##
## 附加到 PanelContainer 节点上，通过 @export 属性配置面板类型
@tool
extends PanelContainer


## ============================================================================
## 导出属性
## ============================================================================

@export var panel_variant: GlassPanel.PanelVariant = GlassPanel.PanelVariant.DEFAULT:
	set(value):
		panel_variant = value
		_update_style()

@export var show_left_accent: bool = false:
	set(value):
		show_left_accent = value
		_update_accent_bar()

@export var accent_color: Color = Color(0.87, 0.7, 0.16):
	set(value):
		accent_color = value
		_update_accent_bar()


## ============================================================================
## 私有变量
## ============================================================================

var _accent_bar: ColorRect = null


## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	_update_style()
	_update_accent_bar()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_style()


## ============================================================================
## 私有方法
## ============================================================================

func _update_style() -> void:
	GlassPanel.apply_to_panel(self, panel_variant)


func _update_accent_bar() -> void:
	if show_left_accent:
		if not _accent_bar:
			_accent_bar = ColorRect.new()
			_accent_bar.name = "AccentBar"
			_accent_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(_accent_bar)
			_accent_bar.set_anchors_preset(Control.PRESET_LEFT_WIDE)
			_accent_bar.custom_minimum_size.x = GlassPanel.ACCENT_BAR_WIDTH
			_accent_bar.size.x = GlassPanel.ACCENT_BAR_WIDTH

		_accent_bar.color = accent_color
		_accent_bar.visible = true
	else:
		if _accent_bar:
			_accent_bar.visible = false
