## 可视化测试 UI 控制脚本
##
## 通过消息事件控制精灵
extends Control
class_name VisualTestUI

## ========== 节点引用 ==========

## 精灵控制器引用（可选，用于直接获取状态）
@onready var _sprite_controller: Node2D = get_node_or_null("/root/MessageVisualTest/CanvasLayer/SpriteController")

## 事件日志 Label
@onready var _event_log: RichTextLabel = $VBoxContainer/MainArea/RightPanel/RightVBox/EventLog

## 状态信息 Label
@onready var _status_label: Label = $VBoxContainer/MainArea/RightPanel/RightVBox/StatusLabel

## ========== 生命周期 ==========

func _ready() -> void:
	_connect_button_signals()
	_connect_message_server()
	_update_status_display()

	# 启用消息服务器日志
	MessageServer.set_logging_enabled(true)

	# 定时更新状态显示
	var timer := Timer.new()
	timer.wait_time = 0.1
	timer.autostart = true
	timer.timeout.connect(_update_status_display)
	add_child(timer)


## ========== 信号连接 ==========

## 连接按钮信号
func _connect_button_signals() -> void:
	# 缩放按钮
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/ScaleHBox/ZoomInButton.pressed.connect(func(): _send_scale_message(1.5))
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/ScaleHBox/ZoomOutButton.pressed.connect(func(): _send_scale_message(0.67))
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/ScaleHBox/ResetButton.pressed.connect(_send_reset_message)

	# 动画按钮
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/AnimationHBox/RotateButton.pressed.connect(_send_rotate_message)
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/AnimationHBox/JumpButton.pressed.connect(_send_jump_message)
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/AnimationHBox/BlinkButton.pressed.connect(_send_blink_message)

	# 颜色按钮
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/ColorHBox/RedButton.pressed.connect(func(): _send_color_message(Color.RED))
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/ColorHBox/GreenButton.pressed.connect(func(): _send_color_message(Color.GREEN))
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/ColorHBox/BlueButton.pressed.connect(func(): _send_color_message(Color.BLUE))
	$VBoxContainer/MainArea/LeftPanel/LeftScroll/LeftVBox/ColorHBox/WhiteButton.pressed.connect(func(): _send_color_message(Color.WHITE))

	# 关闭按钮
	$VBoxContainer/TitlePanel/HBoxContainer/CloseButton.pressed.connect(get_tree().quit)


## 连接消息服务器信号
func _connect_message_server() -> void:
	if not MessageServer.message_sent.is_connected(_on_message_sent):
		MessageServer.message_sent.connect(_on_message_sent)


## ========== 消息发送 ==========

## 发送缩放消息
func _send_scale_message(multiplier: float) -> void:
	var message = SpriteScaleMessage.new(multiplier)
	message.sender = self
	MessageServer.send_message(message)


## 发送旋转消息
func _send_rotate_message() -> void:
	var message = SpriteRotateMessage.new(90.0)
	message.sender = self
	MessageServer.send_message(message)


## 发送跳跃消息
func _send_jump_message() -> void:
	var message = SpriteJumpMessage.new(100.0)
	message.sender = self
	MessageServer.send_message(message)


## 发送闪烁消息
func _send_blink_message() -> void:
	var message = SpriteBlinkMessage.new(3)
	message.sender = self
	MessageServer.send_message(message)


## 发送颜色消息
func _send_color_message(color: Color) -> void:
	var message = SpriteColorMessage.new(color)
	message.sender = self
	MessageServer.send_message(message)


## 发送重置消息
func _send_reset_message() -> void:
	var message = SpriteResetMessage.new()
	message.sender = self
	MessageServer.send_message(message)


## ========== 事件处理 ==========

## 消息发送回调（用于日志显示）
func _on_message_sent(message: Message) -> void:
	var msg_type := message.get_message_type()
	var log_text := ""

	match msg_type:
		&"SpriteScaleMessage":
			var multiplier = message.get("scale_multiplier")
			log_text = "[color=yellow]• 收到 SpriteScaleMessage (%.1fx)[/color]" % multiplier
		&"SpriteRotateMessage":
			var degrees = message.get("rotation_degrees")
			log_text = "[color=cyan]• 收到 SpriteRotateMessage (%.0f°)[/color]" % degrees
		&"SpriteJumpMessage":
			var height = message.get("jump_height")
			log_text = "[color=green]• 收到 SpriteJumpMessage (%.0f px)[/color]" % height
		&"SpriteBlinkMessage":
			var count = message.get("blink_count")
			log_text = "[color=magenta]• 收到 SpriteBlinkMessage (%d 次)[/color]" % count
		&"SpriteColorMessage":
			var color: Color = message.get("color")
			var color_name = _get_color_name(color)
			log_text = "[color=%s]• 收到 SpriteColorMessage (%s)[/color]" % [_color_to_bbcode(color), color_name]
		&"SpriteResetMessage":
			log_text = "[color=white]• 收到 SpriteResetMessage[/color]"

	if log_text != "" and _event_log:
		_event_log.append_text(log_text + "\n")


## 更新状态显示
func _update_status_display() -> void:
	if not _sprite_controller:
		return

	# 使用 call 方法避免类型依赖
	var status = _sprite_controller.call("get_status_info")
	if not status:
		return

	var color: Color = status.get("color", Color.WHITE)
	var color_name = _get_color_name(color)

	if _status_label:
		_status_label.text = "当前状态: %s\n缩放: %.2fx\n旋转: %.0f°\n颜色: %s" % [
			"动画中" if status.get("is_animating", false) else "正常",
			status.get("scale", 1.0),
			fmod(status.get("rotation", 0.0), 360.0),
			color_name
		]


## 获取颜色名称
func _get_color_name(color: Color) -> String:
	if color == Color.RED:
		return "红色"
	elif color == Color.GREEN:
		return "绿色"
	elif color == Color.BLUE:
		return "蓝色"
	elif color == Color.WHITE:
		return "白色"
	elif color == Color.YELLOW:
		return "黄色"
	elif color == Color.CYAN:
		return "青色"
	elif color == Color.MAGENTA:
		return "品红"
	else:
		return "自定义"


## 颜色转 BBCode
func _color_to_bbcode(color: Color) -> String:
	return "#%02x%02x%02x" % [int(color.r * 255), int(color.g * 255), int(color.b * 255)]


## ========== 输入处理 ==========

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1, KEY_KP_1:
				_send_scale_message(1.5)
			KEY_2, KEY_KP_2:
				_send_scale_message(0.67)
			KEY_3, KEY_KP_3:
				_send_reset_message()
			KEY_4, KEY_KP_4:
				_send_rotate_message()
			KEY_5, KEY_KP_5:
				_send_jump_message()
			KEY_6, KEY_KP_6:
				_send_blink_message()
			KEY_R:
				_send_reset_message()
			KEY_ESCAPE:
				get_tree().quit()
