## 单位攻击消息
##
## 当单位执行攻击行为时发送
extends Message
class_name UnitAttackedMessage

## 攻击单位 ID
var attacker_id: StringName = &""

## 目标单位 ID
var target_id: StringName = &""

## 攻击类型（"normal", "skill", "counter" 等）
var attack_type: StringName = &"normal"

## 基础伤害值
var base_damage: int = 0


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"UnitAttackedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["attacker_id"] = attacker_id
	info["target_id"] = target_id
	info["attack_type"] = attack_type
	info["base_damage"] = base_damage
	return info
