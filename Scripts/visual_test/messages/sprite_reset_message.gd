## 精灵重置消息
##
## 当需要重置精灵状态时发送
extends Message
class_name SpriteResetMessage


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"SpriteResetMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	return info
