extends Resource
class_name TileBlockData

## 地形类型ID（唯一标识符）
@export var tile_type: StringName = &""

## 显示名称（中文）
@export var display_name: String = ""

## 地形分类（基础/进阶/特殊）
@export var category: StringName = &"" # &"basic", &"advanced", &"special"

## 元素词条类型
@export var element_type: StringName = &"" # &"none", &"fire", &"water", &"earth", &"air", &"nature", &"ice"

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
