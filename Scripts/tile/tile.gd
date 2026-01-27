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
@onready var _icon_layer: TextureRect = $IconLayer
@onready var _border_layer: Panel = $BorderLayer

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

	# 初始化边框样式
	_init_border_style()


## 初始化边框样式
func _init_border_style() -> void:
	if not _border_layer:
		return

	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.3, 0.3, 0.8)  # 默认深灰色边框

	_border_layer.add_theme_stylebox_override("panel", style_box)


## 设置地块数据
func set_data(data) -> void:
	_data = data
	if _icon_layer and data:
		# 从数据文件读取图标路径
		if data.has_method("get") and data.get("icon_path"):
			var icon_path: String = data.get("icon_path")
			if not icon_path.is_empty():
				_icon_layer.texture = load(icon_path)

		# 应用地形颜色
		_apply_terrain_colors(data)


## 获取地块数据
func get_data():
	return _data


## 获取纹理（用于兼容）
func get_texture():
	return _icon_layer.texture if _icon_layer else null


## 应用地形颜色配置
func _apply_terrain_colors(data) -> void:
	if not data:
		return

	# 从数据文件读取颜色配置（TileBlockData 属性已有默认值）
	var main_color: Color = data.main_color
	var border_color: Color = data.border_color

	# 应用图标颜色（纯色覆盖）
	if _icon_layer:
		_icon_layer.modulate = main_color

	# 应用边框颜色
	if _border_layer:
		var style_box := _border_layer.get_theme_stylebox("panel")
		if style_box is StyleBoxFlat:
			style_box.border_color = border_color


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


## 高亮选中（使用地形强调色）
func highlight() -> void:
	is_selected = true
	_update_visual_state()


## 取消高亮
func unhighlight() -> void:
	is_selected = false
	_update_visual_state()


## 更新视觉状态（根据选中、悬停、拖拽高亮状态）
func _update_visual_state() -> void:
	if not _data:
		return

	# 从数据文件读取颜色配置（TileBlockData 属性已有默认值）
	var main_color: Color = _data.main_color
	var border_color: Color = _data.border_color
	var accent_color: Color = _data.accent_color
	var hover_color: Color = _data.hover_color

	# 确定当前应该使用的颜色
	var final_border_color: Color
	var final_icon_color: Color

	if is_selected:
		# 选中状态：使用强调色
		final_border_color = accent_color
		final_icon_color = accent_color
	elif is_drag_highlighted:
		# 拖拽高亮状态：使用淡黄色
		final_border_color = Color(1.2, 1.2, 0.8)
		final_icon_color = main_color
	elif is_hovered:
		# 悬停状态：边框使用悬停高亮色，图标保持主色
		final_border_color = hover_color
		final_icon_color = main_color
	else:
		# 默认状态
		final_border_color = border_color
		final_icon_color = main_color

	# 应用边框颜色
	if _border_layer:
		var style_box := _border_layer.get_theme_stylebox("panel")
		if style_box is StyleBoxFlat:
			style_box.border_color = final_border_color

	# 应用图标颜色
	if _icon_layer:
		_icon_layer.modulate = final_icon_color


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
	_update_visual_state()  # 使用统一的视觉状态更新

	if hovered:
		tile_hovered.emit(self)
	else:
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
	preview.texture = _icon_layer.texture  # 使用图标而非贴图
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
	style_box.border_color = Color(1.0, 0.8, 0.0)
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
	_update_visual_state()  # 使用统一的视觉状态更新


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
	_update_visual_state()  # 使用统一的视觉状态更新


## 检测拖拽结束（使用通知）
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_clear_global_drag_highlight()
