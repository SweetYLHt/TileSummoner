## 地形条目资源
## 单个地形在配置列表中的数据
extends Resource
class_name TerrainEntryResource

## 地形类型
@export var tile_type: TileConstants.TileType

## 可用数量
@export var available_count: int = 99

## 是否为必选地形
@export var is_required: bool = false

## 排序顺序
@export var sort_order: int = 0
