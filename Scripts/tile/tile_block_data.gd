extends Resource
class_name TileBlockData

## 地形类型（枚举值，.tres 中存储为整数）
## 0=GRASSLAND, 1=WATER, 2=SAND, 3=ROCK, 4=FOREST, 5=FARMLAND, 6=LAVA, 7=SWAMP, 8=ICE
@export var tile_type: TileConstants.TileType = TileConstants.TileType.GRASSLAND

## 显示名称（中文）
@export var display_name: String = ""

## 地形分类（枚举值，.tres 中存储为整数）
## 0=BASIC, 1=ADVANCED, 2=SPECIAL
@export var category: TileConstants.TileCategory = TileConstants.TileCategory.BASIC

## 元素词条类型（枚举值，.tres 中存储为整数）
## 0=NONE, 1=FIRE, 2=WATER, 3=EARTH, 4=AIR, 5=NATURE, 6=ICE
@export var element_type: TileConstants.ElementType = TileConstants.ElementType.NONE

## 地形贴图
@export var texture: Texture2D

## 移动力修正（正值加成，负值惩罚）
@export var movement_modifier: int = 0

## 防御加成百分比（0-100）
@export var defense_bonus: int = 0

## 攻击加成百分比（0-100）
@export var attack_bonus: int = 0

## 每秒持续伤害（0为无）
@export var damage_per_second: int = 0

## 每5秒持续恢复（0为无）
@export var heal_per_5sec: int = 0

## 闪避几率（0.0-1.0）
@export var dodge_chance: float = 0.0

## 特殊效果标志位
## bit 0: 可点燃
## bit 1: 可冻结
## bit 2: 可腐蚀
## bit 3: 可减速
## bit 4-7: 预留
@export var special_effects: int = 0

## 元素交互矩阵（8种词条的加成值，索引对应元素类型）
## 0: none, 1: fire, 2: water, 3: earth, 4: air, 5: nature, 6: ice, 7: 预留
@export var affinity_matrix: Array[int] = []

## 消耗后是否保留（岩石特殊属性）
@export var remains_after_consume: bool = false

## 地形描述
@export_multiline var description: String = ""


## ============================================================================
## 动画参数
## ============================================================================

## 切换动画：缩小持续时间（秒）
@export var switch_scale_duration: float = 0.15

## 切换动画：放大持续时间（秒）
@export var switch_scale_out_duration: float = 0.2

## 切换动画：旋转持续时间（秒）
@export var switch_rotation_duration: float = 0.35

## 入场动画：下落持续时间（秒）
@export var spawn_duration: float = 0.5

## 入场动画：下落距离（像素）
@export var spawn_fall_distance: float = 500.0
