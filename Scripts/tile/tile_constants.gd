## 地块类型常量定义
## 集中管理所有地块相关的枚举类型
## 此文件被注册为自动加载，全局可通过 TileConstants 访问
extends Node

## ============================================================================
## 枚举定义
## ============================================================================

## 地形类型枚举
## .tres 文件中存储为整数：0=GRASSLAND, 1=WATER, 2=SAND, 3=ROCK, 4=FOREST,
## 5=FARMLAND, 6=LAVA, 7=SWAMP, 8=ICE
enum TileType {
	GRASSLAND,  # 0
	WATER,      # 1
	SAND,       # 2
	ROCK,       # 3
	FOREST,     # 4
	FARMLAND,   # 5
	LAVA,       # 6
	SWAMP,      # 7
	ICE,        # 8
}

## 元素类型枚举
## .tres 文件中存储为整数：0=NONE, 1=FIRE, 2=WATER, 3=EARTH, 4=AIR, 5=NATURE, 6=ICE
enum ElementType {
	NONE,    # 0
	FIRE,    # 1
	WATER,   # 2
	EARTH,   # 3
	AIR,     # 4
	NATURE,  # 5
	ICE,     # 6
}

## 地形分类枚举
## .tres 文件中存储为整数：0=BASIC, 1=ADVANCED, 2=SPECIAL
enum TileCategory {
	BASIC,     # 0
	ADVANCED,  # 1
	SPECIAL,   # 2
}

## 配置类型枚举
## .tres 文件中存储为整数：0=PLAYER_DEFAULT, 1=ENEMY_EASY, 2=ENEMY_MEDIUM, 3=ENEMY_HARD
enum ConfigType {
	PLAYER_DEFAULT,  # 0
	ENEMY_EASY,      # 1
	ENEMY_MEDIUM,    # 2
	ENEMY_HARD,      # 3
}


## ============================================================================
## 地形类型显示名称（用于UI）
## ============================================================================

## 获取地形类型的中文显示名称
func get_tile_type_name(type: TileType) -> String:
	match type:
		TileType.GRASSLAND: return "草地"
		TileType.WATER: return "水域"
		TileType.SAND: return "沙漠"
		TileType.ROCK: return "岩石"
		TileType.FOREST: return "森林"
		TileType.FARMLAND: return "农田"
		TileType.LAVA: return "熔岩"
		TileType.SWAMP: return "沼泽"
		TileType.ICE: return "冰原"
	return "未知"


## 获取元素类型的中文显示名称
func get_element_type_name(type: ElementType) -> String:
	match type:
		ElementType.NONE: return "无"
		ElementType.FIRE: return "火焰"
		ElementType.WATER: return "水"
		ElementType.EARTH: return "土"
		ElementType.AIR: return "风"
		ElementType.NATURE: return "自然"
		ElementType.ICE: return "冰"
	return "未知"


## 获取地形分类的中文显示名称
func get_category_name(cat: TileCategory) -> String:
	match cat:
		TileCategory.BASIC: return "基础"
		TileCategory.ADVANCED: return "进阶"
		TileCategory.SPECIAL: return "特殊"
	return "未知"


## 获取配置类型的中文显示名称
func get_config_type_name(type: ConfigType) -> String:
	match type:
		ConfigType.PLAYER_DEFAULT: return "玩家默认"
		ConfigType.ENEMY_EASY: return "简单敌人"
		ConfigType.ENEMY_MEDIUM: return "中等敌人"
		ConfigType.ENEMY_HARD: return "困难敌人"
	return "未知"


## ============================================================================
## 获取类型列表
## ============================================================================

## 获取所有地形类型枚举
func get_all_tile_types() -> Array[TileType]:
	return [
		TileType.GRASSLAND,
		TileType.WATER,
		TileType.SAND,
		TileType.ROCK,
		TileType.FOREST,
		TileType.FARMLAND,
		TileType.LAVA,
		TileType.SWAMP,
		TileType.ICE,
	]


## 获取所有元素类型枚举
func get_all_element_types() -> Array[ElementType]:
	return [
		ElementType.NONE,
		ElementType.FIRE,
		ElementType.WATER,
		ElementType.EARTH,
		ElementType.AIR,
		ElementType.NATURE,
		ElementType.ICE,
	]


## 获取所有地形分类枚举
func get_all_categories() -> Array[TileCategory]:
	return [
		TileCategory.BASIC,
		TileCategory.ADVANCED,
		TileCategory.SPECIAL,
	]


## 获取所有配置类型枚举
func get_all_config_types() -> Array[ConfigType]:
	return [
		ConfigType.PLAYER_DEFAULT,
		ConfigType.ENEMY_EASY,
		ConfigType.ENEMY_MEDIUM,
		ConfigType.ENEMY_HARD,
	]


## ============================================================================
## 验证方法
## ============================================================================

## 检查是否为有效的地形类型
func is_valid_tile_type(tile_type: TileType) -> bool:
	return tile_type >= TileType.GRASSLAND and tile_type <= TileType.ICE


## 检查是否为有效的元素类型
func is_valid_element_type(element: ElementType) -> bool:
	return element >= ElementType.NONE and element <= ElementType.ICE


## 检查是否为有效的地形分类
func is_valid_category(category: TileCategory) -> bool:
	return category >= TileCategory.BASIC and category <= TileCategory.SPECIAL


## 检查是否为有效的配置类型
func is_valid_config_type(config_type: ConfigType) -> bool:
	return config_type >= ConfigType.PLAYER_DEFAULT and config_type <= ConfigType.ENEMY_HARD
