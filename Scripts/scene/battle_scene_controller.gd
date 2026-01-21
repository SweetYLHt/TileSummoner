## 战斗场景控制器
##
## 管理战斗场景的初始化和流程
extends Node
class_name BattleSceneController

## 战斗地图生成器
@onready var _map_generator: BattleMapGenerator = $BattleMapGenerator

## 网格管理器
@onready var _grid_manager: GridManager = $BattleMap/Tiles/GridManager

## 返回按钮
@onready var _back_button: Button = $UI/TopBar/BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	call_deferred("_initialize_battle")


## 初始化战斗
func _initialize_battle() -> void:
	var enemy_difficulty: TileConstants.ConfigType = SceneManager.current_enemy_difficulty

	# 检查是否有玩家编辑的配置
	var player_config := SceneManager.get_player_config()

	if player_config.is_empty():
		# 没有编辑配置，使用默认配置
		_map_generator.initialize_battle_map(
			_grid_manager,
			TileConstants.ConfigType.PLAYER_DEFAULT,
			enemy_difficulty
		)
	else:
		# 使用玩家编辑的配置
		_map_generator.initialize_battle_map_with_custom_config(
			_grid_manager,
			player_config,
			enemy_difficulty
		)


## 返回编辑按钮
func _on_back_pressed() -> void:
	SceneManager.transition_to_tile_editor()
