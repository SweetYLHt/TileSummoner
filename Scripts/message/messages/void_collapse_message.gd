## 虚空坠毁消息
##
## 当单位被推入虚空（无地块区域）时发送
extends Message
class_name VoidCollapseMessage

## 坠毁单位的位置
var position: Vector2i = Vector2i.ZERO

## 坠毁的单位 ID
var unit_id: StringName = &""

## 是否是被敌方击入虚空
var is_knockback: bool = false


func _init() -> void:
	priority = MessagePriority.HIGH


func get_message_type() -> StringName:
	return &"VoidCollapseMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["position"] = position
	info["unit_id"] = unit_id
	info["is_knockback"] = is_knockback
	return info
