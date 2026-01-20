extends Node

## 测试地块系统

@onready var _grid_manager = $BattleMap/Tiles/GridManager
@onready var _map_generator = $BattleMapGenerator


func _ready() -> void:
	print("=== 地块系统测试开始 ===")

	# 测试1: 检查TileDatabase是否正确加载
	_test_tile_database()

	# 测试2: 检查配置文件是否正确加载
	_test_config_loading()

	# 测试3: 生成地图并播放动画
	_test_map_generation()

	print("=== 地块系统测试完成 ===")


## 测试TileDatabase
func _test_tile_database() -> void:
	print("\n[测试1] TileDatabase加载测试")

	var all_types := tileDatabase.get_all_tile_types()
	print("已加载地形类型数量: %d" % all_types.size())

	for tile_type in all_types:
		var data: Resource = tileDatabase.get_tile_data(tile_type)
		if data:
			print("  ✓ %s: %s (贴图: %s)" % [tile_type, data.display_name, "已加载" if data.texture else "未加载"])
		else:
			print("  ✗ %s: 加载失败" % tile_type)

	assert(all_types.size() == 9, "应该有9种地形类型")


## 测试配置文件加载
func _test_config_loading() -> void:
	print("\n[测试2] 配置文件加载测试")

	var player_config: Resource = _map_generator.load_player_config(&"player_default")
	var enemy_config: Resource = _map_generator.load_enemy_config(&"enemy_easy")

	if player_config:
		print("  ✓ 玩家配置加载成功: %d格" % player_config.get_size())
	else:
		print("  ✗ 玩家配置加载失败")

	if enemy_config:
		print("  ✓ 敌方配置加载成功: %d格" % enemy_config.get_size())
	else:
		print("  ✗ 敌方配置加载失败")

	assert(player_config != null, "玩家配置不能为空")
	assert(enemy_config != null, "敌方配置不能为空")
	assert(player_config.get_size() == 28, "玩家配置应该有28格")
	assert(enemy_config.get_size() == 35, "敌方配置应该有35格")


## 测试地图生成
func _test_map_generation() -> void:
	print("\n[测试3] 地图生成测试")

	# 生成地图
	_map_generator.initialize_battle_map(_grid_manager, &"player_default", &"enemy_easy")

	# 等待一帧，让网格生成完成
	await get_tree().process_frame

	# 检查网格
	var tiles: Array = _grid_manager.get_all_tiles()
	print("  ✓ 生成的地块数量: %d" % tiles.size())

	assert(tiles.size() == 63, "应该生成63个地块")

	# 检查坐标计算
	var first_tile: Node = _grid_manager.get_tile(Vector2i(0, 0))
	var last_tile: Node = _grid_manager.get_tile(Vector2i(6, 8))

	if first_tile and last_tile:
		print("  ✓ 左上角地块坐标: (%.1f, %.1f)" % [first_tile.position.x, first_tile.position.y])
		print("  ✓ 右下角地块坐标: (%.1f, %.1f)" % [last_tile.position.x, last_tile.position.y])

	print("\n请观察地图生成动画（从上到下，每行延迟0.05秒）")


## 输入测试
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
