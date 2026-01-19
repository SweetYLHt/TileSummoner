## 控制带变更消息
##
## 当控制带（中央区域）的控制权发生变化时发送
extends Message
class_name ZoneControlChangedMessage

## 控制带位置
var position: Vector2i = Vector2i.ZERO

## 新的控制器玩家 ID（0 表示中立）
var new_controller_id: int = 0

## 旧的控制器玩家 ID
var old_controller_id: int = 0


func _init() -> void:
	priority = MessagePriority.HIGH


func get_message_type() -> StringName:
	return &"ZoneControlChangedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["position"] = position
	info["new_controller_id"] = new_controller_id
	info["old_controller_id"] = old_controller_id
	return info
