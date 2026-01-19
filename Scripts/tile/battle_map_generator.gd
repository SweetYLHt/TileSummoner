extends Node
class_name BattleMapGenerator

## 加载敌方配置
func load_enemy_config(difficulty: StringName = &"enemy_easy") -> TileConfig:
	var path := "res://Resources/Tiles/Configs/%s.tres" % difficulty
	var config: TileConfig = load(path) as TileConfig
	if not config:
		push_error("Failed to load enemy config: %s" % difficulty)
	return config


## 加载玩家配置
func load_player_config(config_name: StringName = &"player_default") -> TileConfig:
	var path := "res://Resources/Tiles/Configs/%s.tres" % config_name
	var config: TileConfig = load(path) as TileConfig
	if not config:
		push_error("Failed to load player config: %s" % config_name)
	return config


## 生成完整地图配置（用于验证）
func generate_full_map(player_config: TileConfig, enemy_config: TileConfig) -> Array:
	var full_map: Array = []

	# 敌方35格
	for i in range(35):
		full_map.append(enemy_config.get_tile_at(i))

	# 我方28格
	for i in range(28):
		full_map.append(player_config.get_tile_at(i))

	return full_map


## 初始化战斗地图
func initialize_battle_map(grid_manager: GridManager,
						   player_config_name: StringName = &"player_default",
						   enemy_config_name: StringName = &"enemy_easy") -> void:
	# 加载配置
	var player_config := load_player_config(player_config_name)
	var enemy_config := load_enemy_config(enemy_config_name)

	if not player_config or not enemy_config:
		push_error("Failed to load configs")
		return

	# 获取配置数组
	var player_tiles := player_config.get_config()
	var enemy_tiles := enemy_config.get_config()

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
func get_available_enemy_configs() -> Array[StringName]:
	return [&"enemy_easy", &"enemy_medium", &"enemy_hard"]
