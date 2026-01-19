## 金币获得消息
##
## 当玩家获得金币时发送
extends Message
class_name GoldEarnedMessage

## 玩家 ID
var player_id: int = 0

## 获得的金币数量
var amount: int = 0

## 当前金币总数
var current_gold: int = 0

## 获得原因（"kill", "passive", "quest", "tile" 等）
var source: StringName = &""


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"GoldEarnedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["player_id"] = player_id
	info["amount"] = amount
	info["current_gold"] = current_gold
	info["source"] = source
	return info
