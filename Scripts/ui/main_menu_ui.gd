## 主菜单UI控制器
##
## 处理主菜单的用户交互
extends Control
class_name MainMenuUI


func _ready() -> void:
	_connect_signals()


## 连接按钮信号
func _connect_signals() -> void:
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)


## 开始游戏按钮
func _on_start_pressed() -> void:
	SceneManager.transition_to_tile_editor()


## 设置按钮
func _on_settings_pressed() -> void:
	SceneManager.transition_to_settings()


## 退出按钮
func _on_exit_pressed() -> void:
	get_tree().quit()
