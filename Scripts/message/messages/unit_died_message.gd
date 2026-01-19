## 单位死亡消息
##
## 当单位被击败或销毁时发送
extends Message
class_name UnitDiedMessage

## 死亡单位 ID
var unit_id: StringName = &""

## 单位类型
var unit_type: StringName = &""

## 死亡位置
var position: Vector2i = Vector2i.ZERO

## 所属玩家 ID
var player_id: int = 0

## 死亡原因（"killed", "void", "skill", "timeout" 等）
var death_cause: StringName = &"killed"

## 凶手单位 ID（如果是被击杀）
var killer_id: StringName = &""


func _init() -> void:
	priority = MessagePriority.HIGH


func get_message_type() -> StringName:
	return &"UnitDiedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["unit_id"] = unit_id
	info["unit_type"] = unit_type
	info["position"] = position
	info["player_id"] = player_id
	info["death_cause"] = death_cause
	info["killer_id"] = killer_id
	return info
