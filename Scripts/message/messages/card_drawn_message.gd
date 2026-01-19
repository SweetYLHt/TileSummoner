## 卡牌抽取消息
##
## 当玩家抽牌时发送
extends Message
class_name CardDrawnMessage

## 玩家 ID
var player_id: int = 0

## 抽取的卡牌 ID
var card_id: StringName = &""

## 当前手牌数量
var hand_size: int = 0

## 抽牌来源（"deck", "effect", "refund" 等）
var source: StringName = &"deck"


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"CardDrawnMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["player_id"] = player_id
	info["card_id"] = card_id
	info["hand_size"] = hand_size
	info["source"] = source
	return info
