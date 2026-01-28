## 场景管理器
##
## 负责游戏场景之间的切换和设置弹窗管理
extends Node
class_name SceneManager

## 场景路径常量
const MAIN_MENU_SCENE: String = "res://Scenes/main_menu.tscn"
const TILE_EDITOR_SCENE: String = "res://Scenes/tile_editor.tscn"
const TERRAIN_CONFIG_SCENE: String = "res://Scenes/ui/terrain_config/terrain_config_ui.tscn"
const BATTLE_SCENE: String = "res://Scenes/battle_scene.tscn"
const SETTINGS_SCENE: String = "res://Scenes/ui/settings_menu.tscn"
const SETTINGS_POPUP_SCENE: String = "res://Scenes/ui/settings_popup/settings_popup.tscn"

## 当前设置弹窗实例
static var _settings_popup: SettingsPopup = null

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


## 切换到地形配置界面
static func transition_to_terrain_config() -> void:
	_change_scene(TERRAIN_CONFIG_SCENE)


## 切换到战斗场景
static func transition_to_battle(enemy_difficulty: TileConstants.ConfigType = TileConstants.ConfigType.ENEMY_EASY) -> void:
	current_enemy_difficulty = enemy_difficulty
	_change_scene(BATTLE_SCENE)


## 切换到设置界面
static func transition_to_settings() -> void:
	_change_scene(SETTINGS_SCENE)


## 显示设置弹窗（推荐方式）
static func show_settings_popup() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if not tree:
		push_error("Failed to get SceneTree")
		return

	# 如果弹窗已存在且可见，不重复创建
	if _settings_popup and is_instance_valid(_settings_popup) and _settings_popup.visible:
		return

	# 如果弹窗实例已存在但不可见，直接显示
	if _settings_popup and is_instance_valid(_settings_popup):
		_settings_popup.show_popup()
		return

	# 创建新的弹窗实例
	var popup_scene := load(SETTINGS_POPUP_SCENE) as PackedScene
	if not popup_scene:
		push_error("Failed to load settings popup scene")
		return

	_settings_popup = popup_scene.instantiate() as SettingsPopup
	if not _settings_popup:
		push_error("Failed to instantiate settings popup")
		return

	# 添加到当前场景根节点
	tree.current_scene.add_child(_settings_popup)
	_settings_popup.show_popup()

	# 弹窗关闭时清理引用
	_settings_popup.closed.connect(_on_settings_popup_closed)


## 设置弹窗关闭回调
static func _on_settings_popup_closed() -> void:
	if _settings_popup and is_instance_valid(_settings_popup):
		_settings_popup.queue_free()
		_settings_popup = null


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
