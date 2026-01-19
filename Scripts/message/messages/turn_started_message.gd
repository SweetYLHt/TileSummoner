## 回合开始消息
##
## 当新回合开始时发送
extends Message
class_name TurnStartedMessage

## 当前回合数
var turn_number: int = 0

## 当前行动玩家 ID
var current_player_id: int = 0


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"TurnStartedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["turn_number"] = turn_number
	info["current_player_id"] = current_player_id
	return info
