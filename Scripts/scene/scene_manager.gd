## 场景管理器
##
## 负责游戏场景之间的切换
extends Node
class_name SceneManager

## 场景路径常量
const MAIN_MENU_SCENE: String = "res://Scenes/main_menu.tscn"
const TILE_EDITOR_SCENE: String = "res://Scenes/tile_editor.tscn"
const BATTLE_SCENE: String = "res://Scenes/battle_scene.tscn"
const SETTINGS_SCENE: String = "res://Scenes/ui/settings_menu.tscn"

## 当前敌方难度（场景间传递）
static var current_enemy_difficulty: TileConstants.ConfigType = TileConstants.ConfigType.ENEMY_EASY

## 当前玩家配置（场景间传递）
static var current_player_config: Array[TileConstants.TileType] = []


## 切换到主菜单
static func transition_to_main_menu() -> void:
	_change_scene(MAIN_MENU_SCENE)


## 切换到地形编辑界面
static func transition_to_tile_editor() -> void:
	_change_scene(TILE_EDITOR_SCENE)


## 切换到战斗场景
static func transition_to_battle(enemy_difficulty: TileConstants.ConfigType = TileConstants.ConfigType.ENEMY_EASY) -> void:
	current_enemy_difficulty = enemy_difficulty
	_change_scene(BATTLE_SCENE)


## 切换到设置界面
static func transition_to_settings() -> void:
	_change_scene(SETTINGS_SCENE)


## 内部场景切换方法
static func _change_scene(scene_path: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree:
		var error := tree.change_scene_to_file(scene_path)
		if error != OK:
			push_error("Failed to change scene to: %s, error: %d" % [scene_path, error])
	else:
		push_error("Failed to get SceneTree")


## ============ 玩家配置传递 ============

## 设置玩家配置
static func set_player_config(config: Array[TileConstants.TileType]) -> void:
	current_player_config = config.duplicate()


## 获取玩家配置
static func get_player_config() -> Array[TileConstants.TileType]:
	return current_player_config.duplicate()


## 清除玩家配置
static func clear_player_config() -> void:
	current_player_config = []
