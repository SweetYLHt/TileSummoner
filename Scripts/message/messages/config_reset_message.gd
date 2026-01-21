## 配置重置消息
##
## 当地形配置被重置为默认值时发送
extends Message
class_name ConfigResetMessage

## 重置类型（player/enemy）
var reset_type: StringName = &""


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"ConfigResetMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["reset_type"] = reset_type
	return info
