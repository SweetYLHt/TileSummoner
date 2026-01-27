## 地形配置数据资源
## 用于存储地形配置 UI 的可用地形列表
extends Resource
class_name TerrainConfigData
## 地形条目列表
@export var terrain_entries: Array[TerrainEntryResource] = []
