extends Node
class_name BattleMapGenerator

## 配置类型到文件名的映射
const CONFIG_FILE_NAMES: Dictionary = {
	TileConstants.ConfigType.PLAYER_DEFAULT: "player_default",
	TileConstants.ConfigType.ENEMY_EASY: "enemy_easy",
	TileConstants.ConfigType.ENEMY_MEDIUM: "enemy_medium",
	TileConstants.ConfigType.ENEMY_HARD: "enemy_hard",
}


## 加载敌方配置
func load_enemy_config(difficulty: TileConstants.ConfigType = TileConstants.ConfigType.ENEMY_EASY) -> TileConfig:
	var file_name: String = CONFIG_FILE_NAMES.get(difficulty, "enemy_easy")
	var path := "res://Resources/Tiles/Configs/%s.tres" % file_name
	var config: TileConfig = load(path) as TileConfig
	if not config:
		push_error("Failed to load enemy config: %s" % file_name)
	return config


## 加载玩家配置
func load_player_config(config_type: TileConstants.ConfigType = TileConstants.ConfigType.PLAYER_DEFAULT) -> TileConfig:
	var file_name: String = CONFIG_FILE_NAMES.get(config_type, "player_default")
	var path := "res://Resources/Tiles/Configs/%s.tres" % file_name
	var config: TileConfig = load(path) as TileConfig
	if not config:
		push_error("Failed to load player config: %s" % file_name)
	return config


## 生成完整地图配置（用于验证）
func generate_full_map(player_config: TileConfig, enemy_config: TileConfig) -> Array[TileConstants.TileType]:
	var full_map: Array[TileConstants.TileType] = []

	# 敌方35格
	for i in range(35):
		full_map.append(enemy_config.get_tile_at(i))

	# 我方28格
	for i in range(28):
		full_map.append(player_config.get_tile_at(i))

	return full_map


## 初始化战斗地图
func initialize_battle_map(grid_manager: GridManager,
						   player_config_type: TileConstants.ConfigType = TileConstants.ConfigType.PLAYER_DEFAULT,
						   enemy_config_type: TileConstants.ConfigType = TileConstants.ConfigType.ENEMY_EASY) -> void:
	# 加载配置
	var player_config := load_player_config(player_config_type)
	var enemy_config := load_enemy_config(enemy_config_type)

	if not player_config or not enemy_config:
		push_error("Failed to load configs")
		return

	# 获取配置数组
	var player_tiles := player_config.get_player_tiles()
	var enemy_tiles := enemy_config.get_enemy_tiles()

	# 生成网格
	grid_manager.create_grid(enemy_tiles, player_tiles)

	# 播放入场动画
	_play_spawn_animation(grid_manager)


## 播放入场动画（从上到下）
func _play_spawn_animation(grid_manager: GridManager) -> void:
	for y in range(9):
		for x in range(7):
			var tile = grid_manager.get_tile(Vector2i(x, y))
			if tile:
				var delay := float(y) * 0.05 # 每行延迟0.05秒
				tile.play_spawn_animation(delay)


## 获取可用敌方配置列表
func get_available_enemy_configs() -> Array[TileConstants.ConfigType]:
	return [
		TileConstants.ConfigType.ENEMY_EASY,
		TileConstants.ConfigType.ENEMY_MEDIUM,
		TileConstants.ConfigType.ENEMY_HARD,
	]


## ============ 自定义配置初始化 ============

## 使用自定义玩家配置初始化战斗地图
func initialize_battle_map_with_custom_config(
	grid_manager: GridManager,
	player_config: Array[TileConstants.TileType],
	enemy_config_type: TileConstants.ConfigType
) -> void:
	# 加载敌方配置
	var enemy_config := load_enemy_config(enemy_config_type)

	if not enemy_config:
		push_error("Failed to load enemy config: %d" % enemy_config_type)
		return

	# 获取敌方配置数组
	var enemy_tiles := enemy_config.get_enemy_tiles()

	# 生成网格
	grid_manager.create_grid(enemy_tiles, player_config)

	# 播放入场动画
	_play_spawn_animation(grid_manager)
