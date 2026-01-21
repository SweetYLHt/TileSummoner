## 地块变更消息
##
## 当地块类型发生变化时发送
extends Message
class_name TileChangedMessage

## 变更的网格坐标
var cell: Vector2i = Vector2i.ZERO

## 原地形类型
var old_type: TileConstants.TileType = TileConstants.TileType.GRASSLAND

## 新地形类型
var new_type: TileConstants.TileType = TileConstants.TileType.GRASSLAND


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"TileChangedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["cell"] = cell
	info["old_type"] = old_type
	info["new_type"] = new_type
	return info
