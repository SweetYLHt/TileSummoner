## 单位召唤消息
##
## 当新单位被召唤到战场时发送
extends Message
class_name UnitSpawnedMessage

## 单位唯一 ID
var unit_id: StringName = &""

## 单位类型 ID
var unit_type: StringName = &""

## 召唤位置
var position: Vector2i = Vector2i.ZERO

## 所属玩家 ID
var player_id: int = 0

## 召唤方式（"card", "skill", "effect" 等）
var spawn_method: StringName = &"card"


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"UnitSpawnedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["unit_id"] = unit_id
	info["unit_type"] = unit_type
	info["position"] = position
	info["player_id"] = player_id
	info["spawn_method"] = spawn_method
	return info
