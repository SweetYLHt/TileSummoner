extends Sprite2D
class_name Tile

## 地块数据
var _data

## 网格坐标
var grid_position: Vector2i

## 是否可编辑
var is_editable: bool = false

## Tween引用
var _tween: Tween

## 选中状态（编辑界面用）
var is_selected: bool = false


## 设置地块数据
func set_data(data) -> void:
	_data = data
	texture = data.texture


## 获取地块数据
func get_data():
	return _data


## 播放切换动画（编辑界面）
func play_switch_animation() -> void:
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)

	# 缩放：先缩小到0，再弹回1
	scale = Vector2.ONE
	_tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)

	# 旋转：360度翻转
	_tween.tween_property(self, "rotation", 0.0, 0.35)\
		.from(PI * 2)


## 播放入场动画（战斗地图）
func play_spawn_animation(delay: float) -> void:
	if _tween:
		_tween.kill()

	var target_pos := position
	position.y -= 500  # 从上方500像素开始

	# Godot 4.x: 使用 SceneTreeTimer 实现延迟
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	_tween = create_tween()
	_tween.tween_property(self, "position", target_pos, 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BOUNCE)


## 高亮选中
func highlight() -> void:
	is_selected = true
	modulate = Color.YELLOW


## 取消高亮
func unhighlight() -> void:
	is_selected = false
	modulate = Color.WHITE


## 清理
func _exit_tree() -> void:
	if _tween:
		_tween.kill()
