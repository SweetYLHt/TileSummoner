## 断路消息
##
## 当主路连通性被破坏时发送，触发判负条件
extends Message
class_name PathBrokenMessage

## 断路的网格坐标
var broken_cell: Vector2i = Vector2i.ZERO

## 受影响的玩家 ID
var player_id: int = 0


func _init() -> void:
	priority = MessagePriority.CRITICAL


func get_message_type() -> StringName:
	return &"PathBrokenMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["broken_cell"] = broken_cell
	info["player_id"] = player_id
	return info
