## 伤害结算消息
##
## 当伤害实际生效时发送
extends Message
class_name DamageDealtMessage

## 伤害来源单位 ID
var source_id: StringName = &""

## 目标单位 ID
var target_id: StringName = &""

## 实际伤害值
var damage: int = 0

## 伤害类型（"physical", "magical", "true" 等）
var damage_type: StringName = &"physical"

## 是否是暴击
var is_critical: bool = false

## 目标是否死亡
var is_lethal: bool = false


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"DamageDealtMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["source_id"] = source_id
	info["target_id"] = target_id
	info["damage"] = damage
	info["damage_type"] = damage_type
	info["is_critical"] = is_critical
	info["is_lethal"] = is_lethal
	return info
