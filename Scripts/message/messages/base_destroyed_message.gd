## 基地摧毁消息
##
## 当基地被摧毁时发送（游戏结束条件）
extends Message
class_name BaseDestroyedMessage

## 被摧毁的玩家 ID
var player_id: int = 0

## 获胜的玩家 ID
var winner_id: int = 0

## 摧毁原因（"hp_zero", "special" 等）
var destroy_cause: StringName = &"hp_zero"


func _init() -> void:
	priority = MessagePriority.CRITICAL


func get_message_type() -> StringName:
	return &"BaseDestroyedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["player_id"] = player_id
	info["winner_id"] = winner_id
	info["destroy_cause"] = destroy_cause
	return info
