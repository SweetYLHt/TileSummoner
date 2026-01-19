## 精灵闪烁消息
##
## 当需要执行闪烁效果时发送
extends Message
class_name SpriteBlinkMessage

## 闪烁次数
var blink_count: int = 3


func _init(count: int = 3) -> void:
	blink_count = count
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"SpriteBlinkMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["blink_count"] = blink_count
	return info
