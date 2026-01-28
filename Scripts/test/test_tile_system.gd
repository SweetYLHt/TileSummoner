class_name TestTileSystem
extends GdUnitTestSuite

## 地块系统测试套件
## 测试范围：
## 1. TileDatabase 数据加载验证
## 2. BattleMapGenerator 配置文件加载验证
## 3. GridManager 网格生成验证


# ============ TileDatabase 测试 ============

## 测试1：TileDatabase 能获取所有地形类型
func test_tile_database_returns_all_tile_types() -> void:
	var all_types := tileDatabase.get_all_tile_types()

	assert_that(all_types).is_not_null()
	assert_that(all_types.size()).is_equal(9)


## 测试2：TileDatabase 能加载所有地形数据
func test_tile_database_loads_all_tile_data() -> void:
	var all_types := tileDatabase.get_all_tile_types()

	for tile_type in all_types:
		var data: TileBlockData = tileDatabase.get_tile_data(tile_type)
		assert_that(data).is_not_null()


## 测试3：每个地形数据都有显示名称
func test_tile_data_has_display_name() -> void:
	var all_types := tileDatabase.get_all_tile_types()

	for tile_type in all_types:
		var data: TileBlockData = tileDatabase.get_tile_data(tile_type)
		assert_that(data.display_name).is_not_empty()


## 测试4：每个地形数据都有贴图
func test_tile_data_has_texture() -> void:
	var all_types := tileDatabase.get_all_tile_types()

	for tile_type in all_types:
		var data: TileBlockData = tileDatabase.get_tile_data(tile_type)
		assert_that(data.texture).is_not_null()


## 测试5：验证特定地形类型存在
func test_specific_tile_types_exist() -> void:
	var expected_types := [
		TileConstants.TileType.GRASSLAND,
		TileConstants.TileType.WATER,
		TileConstants.TileType.SAND,
		TileConstants.TileType.ROCK,
		TileConstants.TileType.FOREST,
		TileConstants.TileType.FARMLAND,
		TileConstants.TileType.LAVA,
		TileConstants.TileType.SWAMP,
		TileConstants.TileType.ICE,
	]

	for tile_type in expected_types:
		var is_valid := tileDatabase.is_valid_tile_type(tile_type)
		assert_that(is_valid).is_true()


## 测试6：获取地形显示名称
func test_get_tile_display_name() -> void:
	var display_name := tileDatabase.get_tile_display_name(TileConstants.TileType.GRASSLAND)

	assert_that(display_name).is_not_empty()


# ============ BattleMapGenerator 测试 ============

var _map_generator: BattleMapGenerator


func before_test() -> void:
	_map_generator = BattleMapGenerator.new()
	add_child(_map_generator)
	auto_free(_map_generator)


## 测试7：加载玩家默认配置
func test_load_player_default_config() -> void:
	var config: TileConfig = _map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)

	assert_that(config).is_not_null()
	assert_that(config.get_size()).is_equal(28)


## 测试8：加载简单敌方配置
func test_load_enemy_easy_config() -> void:
	var config: TileConfig = _map_generator.load_enemy_config(TileConstants.ConfigType.ENEMY_EASY)

	assert_that(config).is_not_null()
	assert_that(config.get_size()).is_equal(35)


## 测试9：加载中等敌方配置
func test_load_enemy_medium_config() -> void:
	var config: TileConfig = _map_generator.load_enemy_config(TileConstants.ConfigType.ENEMY_MEDIUM)

	assert_that(config).is_not_null()


## 测试10：加载困难敌方配置
func test_load_enemy_hard_config() -> void:
	var config: TileConfig = _map_generator.load_enemy_config(TileConstants.ConfigType.ENEMY_HARD)

	assert_that(config).is_not_null()


## 测试11：获取可用敌方配置列表
func test_get_available_enemy_configs() -> void:
	var configs: Array[TileConstants.ConfigType] = _map_generator.get_available_enemy_configs()

	assert_that(configs).is_not_null()
	assert_that(configs.size()).is_equal(3)
	assert_that(configs).contains(TileConstants.ConfigType.ENEMY_EASY)
	assert_that(configs).contains(TileConstants.ConfigType.ENEMY_MEDIUM)
	assert_that(configs).contains(TileConstants.ConfigType.ENEMY_HARD)


## 测试12：生成完整地图配置
func test_generate_full_map() -> void:
	var player_config := _map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)
	var enemy_config := _map_generator.load_enemy_config(TileConstants.ConfigType.ENEMY_EASY)

	var full_map: Array[TileConstants.TileType] = _map_generator.generate_full_map(player_config, enemy_config)

	# 敌方35格 + 玩家28格 = 63格
	assert_that(full_map.size()).is_equal(63)


# ============ GridManager 测试 ============

## 测试13：GridManager 默认网格尺寸
func test_grid_manager_default_size() -> void:
	var grid_manager := GridManager.new()
	add_child(grid_manager)
	auto_free(grid_manager)

	# 无配置时使用默认值
	assert_that(grid_manager.get_grid_width()).is_equal(7)
	assert_that(grid_manager.get_grid_height()).is_equal(9)


## 测试14：GridManager 创建网格
func test_grid_manager_creates_grid() -> void:
	var grid_manager := GridManager.new()
	add_child(grid_manager)
	auto_free(grid_manager)

	var player_config := _map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)
	var enemy_config := _map_generator.load_enemy_config(TileConstants.ConfigType.ENEMY_EASY)

	var player_tiles := player_config.get_player_tiles()
	var enemy_tiles := enemy_config.get_enemy_tiles()

	grid_manager.create_grid(enemy_tiles, player_tiles)
	await_idle_frame()

	var all_tiles = grid_manager.get_all_tiles()
	assert_that(all_tiles.size()).is_equal(63)


## 测试15：GridManager 获取特定位置地块
func test_grid_manager_get_tile_at_position() -> void:
	var grid_manager := GridManager.new()
	add_child(grid_manager)
	auto_free(grid_manager)

	var player_config := _map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)
	var enemy_config := _map_generator.load_enemy_config(TileConstants.ConfigType.ENEMY_EASY)

	grid_manager.create_grid(enemy_config.get_enemy_tiles(), player_config.get_player_tiles())
	await_idle_frame()

	# 测试左上角
	var first_tile = grid_manager.get_tile(Vector2i(0, 0))
	assert_that(first_tile).is_not_null()

	# 测试右下角
	var last_tile = grid_manager.get_tile(Vector2i(6, 8))
	assert_that(last_tile).is_not_null()


## 测试16：GridManager 无效坐标返回 null
func test_grid_manager_invalid_position_returns_null() -> void:
	var grid_manager := GridManager.new()
	add_child(grid_manager)
	auto_free(grid_manager)

	var tile = grid_manager.get_tile(Vector2i(-1, -1))
	assert_that(tile).is_null()

	var tile2 = grid_manager.get_tile(Vector2i(100, 100))
	assert_that(tile2).is_null()


## 测试17：GridManager 清空网格
func test_grid_manager_clear_grid() -> void:
	var grid_manager := GridManager.new()
	add_child(grid_manager)
	auto_free(grid_manager)

	var player_config := _map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)
	var enemy_config := _map_generator.load_enemy_config(TileConstants.ConfigType.ENEMY_EASY)

	grid_manager.create_grid(enemy_config.get_enemy_tiles(), player_config.get_player_tiles())
	await_idle_frame()

	grid_manager.clear_grid()
	await_idle_frame()

	var all_tiles = grid_manager.get_all_tiles()
	assert_that(all_tiles.size()).is_equal(0)


# ============ 集成测试 ============

## 测试18：完整地图初始化流程
func test_full_map_initialization() -> void:
	var grid_manager := GridManager.new()
	add_child(grid_manager)
	auto_free(grid_manager)

	_map_generator.initialize_battle_map(
		grid_manager,
		TileConstants.ConfigType.PLAYER_DEFAULT,
		TileConstants.ConfigType.ENEMY_EASY
	)
	await_idle_frame()

	var all_tiles = grid_manager.get_all_tiles()
	assert_that(all_tiles.size()).is_equal(63)


## 测试19：玩家区域地块可编辑
func test_player_area_tiles_are_editable() -> void:
	var grid_manager := GridManager.new()
	add_child(grid_manager)
	auto_free(grid_manager)

	_map_generator.initialize_battle_map(
		grid_manager,
		TileConstants.ConfigType.PLAYER_DEFAULT,
		TileConstants.ConfigType.ENEMY_EASY
	)
	await_idle_frame()

	# 玩家区域从 y=5 开始
	var player_tile = grid_manager.get_tile(Vector2i(0, 5))
	assert_that(player_tile).is_not_null()
	assert_that(player_tile.is_editable).is_true()


## 测试20：敌方区域地块不可编辑
func test_enemy_area_tiles_are_not_editable() -> void:
	var grid_manager := GridManager.new()
	add_child(grid_manager)
	auto_free(grid_manager)

	_map_generator.initialize_battle_map(
		grid_manager,
		TileConstants.ConfigType.PLAYER_DEFAULT,
		TileConstants.ConfigType.ENEMY_EASY
	)
	await_idle_frame()

	# 敌方区域 y=0 到 y=4
	var enemy_tile = grid_manager.get_tile(Vector2i(0, 0))
	assert_that(enemy_tile).is_not_null()
	assert_that(enemy_tile.is_editable).is_false()
