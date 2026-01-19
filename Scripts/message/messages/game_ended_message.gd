## 游戏结束消息
##
## 当游戏结束时发送
extends Message
class_name GameEndedMessage

## 获胜玩家 ID
var winner_id: int = 0

## 失败玩家 ID 列表
var loser_ids: Array[int] = []

## 游戏时长（秒）
var duration_seconds: float = 0.0

## 结束原因（"base_destroyed", "path_broken", "surrender", "timeout" 等）
var end_reason: StringName = &""


func _init() -> void:
	priority = MessagePriority.CRITICAL


func get_message_type() -> StringName:
	return &"GameEndedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["winner_id"] = winner_id
	info["loser_ids"] = loser_ids
	info["duration_seconds"] = duration_seconds
	info["end_reason"] = end_reason
	return info
