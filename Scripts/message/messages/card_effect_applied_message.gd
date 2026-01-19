## 卡牌效果应用消息
##
## 当卡牌效果实际应用时发送
extends Message
class_name CardEffectAppliedMessage

## 卡牌 ID
var card_id: StringName = &""

## 效果类型
var effect_type: StringName = &""

## 效果目标位置
var target_position: Vector2i = Vector2i.ZERO

## 效果目标单位 ID
var target_unit_id: StringName = &""

## 效果值（如伤害量、治疗量等）
var effect_value: int = 0


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"CardEffectAppliedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["card_id"] = card_id
	info["effect_type"] = effect_type
	info["target_position"] = target_position
	info["target_unit_id"] = target_unit_id
	info["effect_value"] = effect_value
	return info
