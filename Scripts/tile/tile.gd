extends Control
class_name Tile

## 地块被点击信号
signal tile_clicked(tile: Tile)

## 鼠标进入信号
signal tile_hovered(tile: Tile)

## 鼠标离开信号
signal tile_unhovered(tile: Tile)

## 拖拽接收信号
signal drop_received(tile: Tile, data: Dictionary)

## 子节点引用
@onready var _texture_rect: TextureRect = $TextureRect

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

## 悬停状态
var is_hovered: bool = false

## 拖拽高亮状态
var is_drag_highlighted: bool = false


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


## 设置地块数据
func set_data(data) -> void:
	_data = data
	if _texture_rect and data:
		_texture_rect.texture = data.texture


## 获取地块数据
func get_data():
	return _data


## 获取纹理（用于兼容）
func get_texture():
	return _texture_rect.texture if _texture_rect else null


## 播放切换动画（编辑界面）
func play_switch_animation() -> void:
	if _tween:
		_tween.kill()

	# 轻微的弹性缩放效果：先稍微缩小，再放大，最后恢复
	_tween = create_tween()

	# 串行动画：1.0 -> 0.85 -> 1.05 -> 1.0
	_tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.08)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.08)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)


## 播放入场动画（战斗地图）
func play_spawn_animation(delay: float) -> void:
	if _tween:
		_tween.kill()

	# 从数据获取动画参数，使用默认值作为后备
	var spawn_duration: float = _data.spawn_duration if _data else 0.5
	var fall_distance: float = _data.spawn_fall_distance if _data else 500.0

	var target_pos := position
	position.y -= fall_distance  # 从上方开始

	# Godot 4.x: 使用 SceneTreeTimer 实现延迟
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	_tween = create_tween()
	_tween.tween_property(self, "position", target_pos, spawn_duration)\
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


## 处理GUI输入事件
func _on_gui_input(event: InputEvent) -> void:
	if not is_editable:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tile_clicked.emit(self)


## 鼠标进入
func _on_mouse_entered() -> void:
	set_hover(true)


## 鼠标离开
func _on_mouse_exited() -> void:
	set_hover(false)


## 设置悬停效果
func set_hover(hovered: bool) -> void:
	if is_hovered == hovered:
		return

	is_hovered = hovered
	if hovered:
		if not is_selected and not is_drag_highlighted:
			modulate = Color(1.2, 1.2, 1.2)  # 轻微高亮
		tile_hovered.emit(self)
	else:
		if not is_selected and not is_drag_highlighted:
			modulate = Color.WHITE
		tile_unhovered.emit(self)


## ============ 拖拽功能 ============

## 当前拖拽高亮的 Tile（静态，全局唯一）
static var _current_drag_highlighted: Tile = null


## 获取拖拽数据（棋盘内拖拽）
func _get_drag_data(_at_position: Vector2) -> Variant:
	if not is_editable:
		return null

	# 创建拖拽数据
	var drag_data: Dictionary = {
		"source": "board",
		"source_tile": self,
		"source_cell": grid_position,
		"tile_type": _data.tile_type
	}

	# 拖拽开始调试信息
	_debug_log_drag_start("board", grid_position, _data.tile_type)

	# 创建拖拽预览
	var preview := _create_drag_preview()
	set_drag_preview(preview)

	return drag_data


## 拖拽开始调试日志
func _debug_log_drag_start(source: String, cell: Vector2i, tile_type: TileConstants.TileType) -> void:
	var tile_name := tileDatabase.get_tile_display_name(tile_type)
	print("[DRAG START] source=%s cell=%s type=%s(%d)" % [source, cell, tile_name, tile_type])


## 创建拖拽预览
func _create_drag_preview() -> Control:
	var preview := TextureRect.new()
	preview.texture = _texture_rect.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(67, 54)
	preview.modulate = Color(1, 1, 1, 0.8)
	preview.z_index = 1000

	# 添加边框效果
	var container := Panel.new()
	container.add_child(preview)
	preview.position = Vector2(0, 0)
	container.custom_minimum_size = Vector2(67, 54)

	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(1.0, 0.8, 0.0)  # 金黄色边框
	container.add_theme_stylebox_override("panel", style_box)

	return container


## 检查是否可以接收拖拽数据
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not is_editable:
		return false

	# 检查数据来源
	var source: String = data.get("source", "") if data is Dictionary else ""

	# 从库存拖拽：必须有 tile_type
	if source == "inventory":
		var can_accept: bool = data.has("tile_type")
		if can_accept:
			_clear_global_drag_highlight()
			_show_drag_highlight()
			_current_drag_highlighted = self
			_debug_log_can_drop("inventory", grid_position, data.get("tile_type"))
		return can_accept

	# 从棋盘内拖拽：必须有 source_tile 且不是自己
	if source == "board":
		var source_tile: Tile = data.get("source_tile")
		var source_cell: Vector2i = data.get("source_cell", Vector2i(-1, -1))
		var can_accept: bool = source_tile != null and source_tile != self
		if can_accept:
			_clear_global_drag_highlight()
			_show_drag_highlight()
			_current_drag_highlighted = self
			_debug_log_can_drop("board", grid_position, source_tile.get_data().tile_type, source_cell)
		return can_accept

	return false


## 拖拽悬停调试日志
func _debug_log_can_drop(source: String, target_cell: Vector2i, tile_type: TileConstants.TileType, source_cell: Vector2i = Vector2i(-1, -1)) -> void:
	var tile_name := tileDatabase.get_tile_display_name(tile_type)
	if source_cell >= Vector2i(0, 0):
		print("[DRAG HOVER] source=%s from=%s to=%s type=%s" % [source, source_cell, target_cell, tile_name])
	else:
		print("[DRAG HOVER] source=%s to=%s type=%s" % [source, target_cell, tile_name])


## 处理拖拽放置
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_debug_log_drop(data)
	_hide_drag_highlight()
	drop_received.emit(self, data)


## 拖拽放置调试日志
func _debug_log_drop(data: Variant) -> void:
	var source: String = data.get("source", "") if data is Dictionary else ""
	var tile_type: TileConstants.TileType = data.get("tile_type", -1)
	var tile_name := tileDatabase.get_tile_display_name(tile_type)

	if source == "board":
		var source_cell: Vector2i = data.get("source_cell", Vector2i(-1, -1))
		print("[DRAG DROP] source=board from=%s to=%s type=%s" % [source_cell, grid_position, tile_name])
	else:
		print("[DRAG DROP] source=%s to=%s type=%s" % [source, grid_position, tile_name])


## 显示拖拽高亮
func _show_drag_highlight() -> void:
	if is_drag_highlighted:
		return

	is_drag_highlighted = true
	modulate = Color(1.2, 1.2, 0.8)  # 淡黄色高亮


## 清除全局拖拽高亮
static func _clear_global_drag_highlight() -> void:
	if _current_drag_highlighted:
		_current_drag_highlighted._hide_drag_highlight()
		_current_drag_highlighted = null


## 隐藏拖拽高亮
func _hide_drag_highlight() -> void:
	if not is_drag_highlighted:
		return

	is_drag_highlighted = false
	# 恢复颜色
	if is_selected:
		modulate = Color.YELLOW
	elif is_hovered:
		modulate = Color(1.2, 1.2, 1.2)
	else:
		modulate = Color.WHITE


## 检测拖拽结束（使用通知）
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_clear_global_drag_highlight()
