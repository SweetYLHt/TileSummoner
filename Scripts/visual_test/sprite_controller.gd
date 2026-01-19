## 精灵控制器
##
## 监听消息事件并控制精灵的动画和变换效果
extends Node2D
class_name SpriteController

## ========== 导出变量 ==========

## 精灵节点引用
@onready var _sprite: Sprite2D = $Sprite2D

## Tween 动画对象（Godot 4.x 中 Tween 不再是节点）
var _tween: Tween = null

## 事件日志 Label（可选）
@export var event_log_label: RichTextLabel = null

## ========== 状态变量 ==========

## 当前缩放
var _current_scale: float = 1.0

## 当前旋转角度
var _current_rotation: float = 0.0

## 当前颜色
var _current_color: Color = Color.WHITE

## 是否正在动画中
var _is_animating: bool = false


## ========== 生命周期 ==========

func _ready() -> void:
	print("[SpriteController] _ready() 开始执行")

	# 将控制器移到屏幕中心 (1280x720 窗口)
	position = Vector2(640, 360)
	print("[SpriteController] 控制器位置设置为: %s" % position)

	# 创建一个白色背景面板作为对比
	var bg := ColorRect.new()
	bg.size = Vector2(200, 200)
	bg.position = Vector2(-100, -100) # 居中
	bg.color = Color.WHITE
	bg.z_index = -1 # 在精灵后面
	add_child(bg)
	print("[SpriteController] 已创建白色背景面板")

	# 初始化精灵
	if _sprite:
		print("[SpriteController] 精灵节点存在!")

		# 精灵在控制器中居中
		_sprite.position = Vector2(0, 0)
		_sprite.scale = Vector2(3.0, 3.0) # 放大3倍，实际300x300
		_sprite.visible = true
		_sprite.z_index = 1000 # 非常高的 z_index 确保在最上层

		print("[SpriteController] 精灵 global_position: %s" % _sprite.global_position)
		print("[SpriteController] 精灵 scale: %s" % _sprite.scale)
		print("[SpriteController] 精灵 z_index: %s" % _sprite.z_index)

	# 设置控制器本身的 z_index
	z_index = 500
	print("[SpriteController] 控制器 z_index: %s" % z_index)

	# 连接消息服务器信号
	if MessageServer.message_sent.is_connected(_on_message_sent):
		MessageServer.message_sent.disconnect(_on_message_sent)
	MessageServer.message_sent.connect(_on_message_sent)

	# 启用消息服务器日志以便调试
	MessageServer.set_logging_enabled(true)

	print("[SpriteController] 初始化完成!")
	print("[SpriteController] 窗口大小应为 1280x720，精灵在中心 (640, 360)")
	print("[SpriteController] 应该能看到白色背景板上的红色方块!")

	# 显式启用 process
	set_process(true)
	print("[SpriteController] 已启用 _process() 调用")
	print("[SpriteController] is_processing(): %s" % is_processing())
	print("[SpriteController] is_inside_tree(): %s" % is_inside_tree())

	# 检查父节点
	var parent_node = get_parent()
	if parent_node:
		print("[SpriteController] 父节点: %s (process_mode: %s)" % [parent_node.name, parent_node.process_mode])

	# 检查是否被暂停（仅用于调试）
	var _is_node_paused := (process_mode != PROCESS_MODE_INHERIT)
	print("[SpriteController] process_mode: %s" % process_mode)

## 调试定时器回调
func _on_debug_timer() -> void:
	print("[SpriteController] === 定时器调试 ===")
	print("[SpriteController] 控制器全局位置: %s" % global_position)

	# 查找精灵节点
	var sprite = find_child("Sprite2D", true, false)
	if sprite:
		print("[SpriteController] 找到精灵节点!")
		print("[SpriteController] 精灵全局位置: %s" % sprite.global_position)
		print("[SpriteController] 精灵 scale: %s" % sprite.scale)
		print("[SpriteController] 精灵可见: %s" % sprite.visible)
		print("[SpriteController] 精灵 z_index: %s" % sprite.z_index)
		if sprite.texture:
			print("[SpriteController] 纹理大小: %s" % sprite.texture.get_size())
		print("[SpriteController] 精灵是否在视口内: 需要视口坐标检查")
	else:
		print("[SpriteController] 警告: 未找到精灵节点!")

	print("[SpriteController] ==================")


## ========== 消息处理 ==========

## 消息发送回调
func _on_message_sent(message: Message) -> void:
	if not message:
		return

	# 根据消息类型分发处理（使用类型名称字符串比较）
	match message.get_message_type():
		&"SpriteScaleMessage":
			_on_scale_message(message)
		&"SpriteRotateMessage":
			_on_rotate_message(message)
		&"SpriteJumpMessage":
			_on_jump_message(message)
		&"SpriteBlinkMessage":
			_on_blink_message(message)
		&"SpriteColorMessage":
			_on_color_message(message)
		&"SpriteResetMessage":
			_on_reset_message(message)


## 处理缩放消息
func _on_scale_message(msg: Message) -> void:
	var multiplier: float = msg.get("scale_multiplier")
	_log_event("收到 SpriteScaleMessage: %.1fx" % multiplier)

	var target_scale: float = _current_scale * multiplier
	_animate_scale(target_scale, 0.3)


## 处理旋转消息
func _on_rotate_message(msg: Message) -> void:
	var degrees: float = msg.get("rotation_degrees")
	_log_event("收到 SpriteRotateMessage: %.0f°" % degrees)

	var target_rotation: float = _current_rotation + degrees
	_animate_rotation(target_rotation, 0.5)


## 处理跳跃消息
func _on_jump_message(msg: Message) -> void:
	var height: float = msg.get("jump_height")
	_log_event("收到 SpriteJumpMessage: %.0f px" % height)

	_animate_jump(height, 0.6)


## 处理闪烁消息
func _on_blink_message(msg: Message) -> void:
	var count: int = msg.get("blink_count")
	_log_event("收到 SpriteBlinkMessage: %d 次" % count)

	_animate_blink(msg.get("blink_count"), 1.0)


## 处理颜色消息
func _on_color_message(msg: Message) -> void:
	var color: Color = msg.get("color")
	var color_name = _get_color_name(color)
	_log_event("收到 SpriteColorMessage: %s" % color_name)

	_animate_color(color, 0.3)


## 处理重置消息
func _on_reset_message(_msg: Message) -> void:
	_log_event("收到 SpriteResetMessage")

	# 同时执行多个动画重置状态
	_animate_scale(1.0, 0.3)
	_animate_rotation(0.0, 0.3)
	_animate_color(Color.WHITE, 0.3)


## ========== 动画方法 ==========

## 缩放动画
func _animate_scale(target: float, duration: float) -> void:
	if not _sprite:
		return

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)

	_tween.tween_property(_sprite, "scale", Vector2(target, target), duration)
	_current_scale = target


## 旋转动画
func _animate_rotation(target: float, duration: float) -> void:
	if not _sprite:
		return

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUART)

	_tween.tween_property(_sprite, "rotation_degrees", target, duration)
	_current_rotation = target


## 跳跃动画（抛物线效果）
func _animate_jump(height: float, duration: float) -> void:
	if not _sprite:
		return

	var original_y := position.y

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUART)

	# 向上跳跃
	_tween.parallel().tween_property(self, "position:y", original_y - height, duration * 0.5)
	_tween.tween_property(self, "position:y", original_y, duration * 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)


## 闪烁动画
func _animate_blink(count: int, duration: float) -> void:
	if not _sprite:
		return

	var blink_duration := duration / (count * 2)

	if _tween:
		_tween.kill()
	_tween = create_tween()

	for i in count:
		# 变透明
		_tween.tween_property(_sprite, "modulate:a", 0.2, blink_duration)
		# 恢复
		_tween.tween_property(_sprite, "modulate:a", 1.0, blink_duration)


## 颜色动画
func _animate_color(target: Color, duration: float) -> void:
	if not _sprite:
		return

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUART)

	_tween.tween_property(_sprite, "modulate", target, duration)
	_current_color = target


## ========== 辅助方法 ==========

## 记录事件到日志
func _log_event(text: String) -> void:
	print("[SpriteController] %s" % text)

	if event_log_label:
		var time_dict := Time.get_time_dict_from_system()
		var timestamp := "[%02d] " % time_dict.get("minute", 0)
		event_log_label.append_text(timestamp + text + "\n")


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
		return "自定义颜色"


## ========== 公共属性 ==========

## 获取当前状态信息
func get_status_info() -> Dictionary:
	return {
		"scale": _current_scale,
		"rotation": _current_rotation,
		"color": _current_color,
		"is_animating": _is_animating
	}
