## 卡牌打出消息
##
## 当玩家打出一张卡牌时发送
extends Message
class_name CardPlayedMessage

## 玩家 ID
var player_id: int = 0

## 卡牌 ID
var card_id: StringName = &""

## 卡牌类型（"unit", "spell", "artifact" 等）
var card_type: StringName = &"unit"

## 目标位置（如果是需要位置的卡牌）
var target_position: Vector2i = Vector2i.ZERO

## 目标单位 ID（如果是需要目标的卡牌）
var target_unit_id: StringName = &""

## 花费的法力值
var mana_cost: int = 0


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"CardPlayedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["player_id"] = player_id
	info["card_id"] = card_id
	info["card_type"] = card_type
	info["target_position"] = target_position
	info["target_unit_id"] = target_unit_id
	info["mana_cost"] = mana_cost
	return info
