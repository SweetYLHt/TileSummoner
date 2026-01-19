## 法力值变化消息
##
## 当玩家法力值发生变化时发送
extends Message
class_name ManaChangedMessage

## 玩家 ID
var player_id: int = 0

## 变化前的法力值
var old_mana: int = 0

## 变化后的法力值
var new_mana: int = 0

## 变化量（可为负）
var delta: int = 0

## 变化原因（"regen", "spend", "gain", "tile" 等）
var reason: StringName = &""


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"ManaChangedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["player_id"] = player_id
	info["old_mana"] = old_mana
	info["new_mana"] = new_mana
	info["delta"] = delta
	info["reason"] = reason
	return info
