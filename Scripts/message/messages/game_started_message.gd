## 游戏开始消息
##
## 当游戏正式启动时发送
extends Message
class_name GameStartedMessage

## 游戏模式（"pvp", "pve", "tutorial" 等）
var game_mode: StringName = &"pvp"

## 玩家 ID 列表
var player_ids: Array[int] = []

## 随机种子
var seed: int = 0


func _init() -> void:
	priority = MessagePriority.HIGH


func get_message_type() -> StringName:
	return &"GameStartedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["game_mode"] = game_mode
	info["player_ids"] = player_ids
	info["seed"] = seed
	return info
