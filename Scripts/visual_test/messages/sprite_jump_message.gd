## 精灵跳跃消息
##
## 当需要执行跳跃动画时发送
extends Message
class_name SpriteJumpMessage

## 跳跃高度（像素）
var jump_height: float = 100.0


func _init(height: float = 100.0) -> void:
	jump_height = height
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"SpriteJumpMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["jump_height"] = jump_height
	return info
