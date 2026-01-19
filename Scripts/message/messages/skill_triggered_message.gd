## 技能触发消息
##
## 当单位技能被触发时发送
extends Message
class_name SkillTriggeredMessage

## 触发技能的单位 ID
var caster_id: StringName = &""

## 技能 ID
var skill_id: StringName = &""

## 技能目标位置
var target_position: Vector2i = Vector2i.ZERO

## 技能目标单位 ID（可能为空）
var target_unit_id: StringName = &""


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"SkillTriggeredMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["caster_id"] = caster_id
	info["skill_id"] = skill_id
	info["target_position"] = target_position
	info["target_unit_id"] = target_unit_id
	return info
