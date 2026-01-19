## 精灵旋转消息
##
## 当需要旋转精灵时发送
extends Message
class_name SpriteRotateMessage

## 旋转角度（度）
var rotation_degrees: float = 90.0


func _init(degrees: float = 90.0) -> void:
	rotation_degrees = degrees
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"SpriteRotateMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["rotation_degrees"] = rotation_degrees
	return info
