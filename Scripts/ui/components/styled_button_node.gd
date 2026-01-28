## 样式化按钮节点脚本
##
## 附加到 Button 节点上，通过 @export 属性配置按钮类型
@tool
extends Button


## ============================================================================
## 导出属性
## ============================================================================

@export var button_type: StyledButton.ButtonType = StyledButton.ButtonType.DEFAULT:
	set(value):
		button_type = value
		_update_style()

@export var left_icon: Texture2D = null:
	set(value):
		left_icon = value
		_update_icon()


## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	_update_style()
	_update_icon()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_style()


## ============================================================================
## 私有方法
## ============================================================================

func _update_style() -> void:
	StyledButton.apply_to_button(self, button_type)


func _update_icon() -> void:
	if left_icon:
		icon = left_icon
		icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		expand_icon = true
	else:
		icon = null
