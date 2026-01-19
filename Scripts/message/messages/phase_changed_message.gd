## 阶段变化消息
##
## 当游戏阶段发生变化时发送
extends Message
class_name PhaseChangedMessage

## 旧阶段（"preparation", "combat", "resolution" 等）
var old_phase: StringName = &""

## 新阶段
var new_phase: StringName = &""

## 当前回合数
var turn_number: int = 0


func _init() -> void:
	priority = MessagePriority.HIGH


func get_message_type() -> StringName:
	return &"PhaseChangedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["old_phase"] = old_phase
	info["new_phase"] = new_phase
	info["turn_number"] = turn_number
	return info
