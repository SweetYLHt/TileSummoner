## 精灵颜色消息
##
## 当需要改变精灵颜色时发送
extends Message
class_name SpriteColorMessage

## 目标颜色
var color: Color = Color.WHITE


func _init(target_color: Color = Color.WHITE) -> void:
	color = target_color
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"SpriteColorMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["color"] = color
	return info
