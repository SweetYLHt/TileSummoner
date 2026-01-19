## 基地受损消息
##
## 当基地受到伤害时发送
extends Message
class_name BaseDamagedMessage

## 受损的玩家 ID
var player_id: int = 0

## 伤害值
var damage: int = 0

## 基地当前生命值
var current_hp: int = 0

## 基地最大生命值
var max_hp: int = 0


func _init() -> void:
	priority = MessagePriority.HIGH


func get_message_type() -> StringName:
	return &"BaseDamagedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["player_id"] = player_id
	info["damage"] = damage
	info["current_hp"] = current_hp
	info["max_hp"] = max_hp
	return info
