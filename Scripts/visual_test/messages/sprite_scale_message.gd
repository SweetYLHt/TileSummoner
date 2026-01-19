## 精灵缩放消息
##
## 当需要改变精灵大小时发送
extends Message
class_name SpriteScaleMessage

## 缩放倍数（1.0 为原始大小）
var scale_multiplier: float = 1.0


func _init(multiplier: float = 1.0) -> void:
	scale_multiplier = multiplier
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"SpriteScaleMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["scale_multiplier"] = scale_multiplier
	return info
