## 地块消耗消息
##
## 当地块被消耗用于召唤单位时发送
extends Message
class_name TileConsumedMessage

## 被消耗的网格坐标
var cell: Vector2i = Vector2i.ZERO

## 消耗前的地形类型
var tile_type: TileConstants.TileType = TileConstants.TileType.GRASSLAND

## 召唤的单位 ID
var summoned_unit_id: StringName = &""


func _init() -> void:
	priority = MessagePriority.NORMAL


func get_message_type() -> StringName:
	return &"TileConsumedMessage"


func get_debug_info() -> Dictionary:
	var info := super.get_debug_info()
	info["cell"] = cell
	info["tile_type"] = tile_type
	info["summoned_unit_id"] = summoned_unit_id
	return info
