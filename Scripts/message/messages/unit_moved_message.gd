## 单位移动消息
##
## 当单位在网格上移动时发送
extends Message
class_name UnitMovedMessage

## 单位唯一 ID
var unit_id: StringName = &""

## 起始位置
var from_position: Vector2i = Vector2i.ZERO

## 目标位置
var to_position: Vector2i = Vector2i.ZERO

## 移动类型（"walk", "fly", "teleport", "knockback" 等）
var move_type: StringName = &"walk"


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"UnitMovedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["unit_id"] = unit_id
	info["from_position"] = from_position
	info["to_position"] = to_position
	info["move_type"] = move_type
	return info
