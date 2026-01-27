## 地形网格槽位
## 用于显示战场网格中的单个槽位，支持拖拽、hover 动画和发光效果
extends Panel
class_name TerrainGridSlot

## 信号：接收拖拽数据
signal drop_data_received(slot: TerrainGridSlot, data: Dictionary)

## ============================================================================
## 预加载
## ============================================================================

const _UIColorUtils := preload("res://Scripts/utils/ui_color_utils.gd")

## ============================================================================
## 导出变量
## ============================================================================

## 槽位行索引
@export var grid_row: int = 0

## 槽位列索引
@export var grid_col: int = 0

## ============================================================================
## 常量
## ============================================================================

## 虚线边框颜色
const DASHED_BORDER_COLOR := Color(0.3, 0.35, 0.4, 0.5)

## 虚线边框 hover 颜色
const DASHED_BORDER_HOVER_COLOR := Color(0.5, 0.55, 0.6, 0.7)

## 空槽位背景色
const EMPTY_BG_COLOR := Color(0.06, 0.08, 0.1, 0.5)

## 空槽位 hover 背景色
const EMPTY_HOVER_BG_COLOR := Color(0.08, 0.1, 0.13, 0.6)

## 拖拽高亮边框色（金色）
const DRAG_HIGHLIGHT_COLOR := Color(0.87, 0.7, 0.16, 1.0)

## ============================================================================
## 节点引用
## ============================================================================

@onready var _dashed_border: Control = $DashedBorder
@onready var _icon: TextureRect = $CenterContainer/Icon
@onready var _add_icon: TextureRect = $CenterContainer/AddIcon

## ============================================================================
## 内部变量
## ============================================================================

## 当前地形类型（-1 表示空）
var _current_terrain: int = -1

## 是否正在 hover
var _is_hovering: bool = false

## 选中状态
var is_selected: bool = false

## 拖拽高亮状态
var is_drag_highlighted: bool = false

## 当前拖拽高亮的槽位（静态）
static var _current_drag_highlighted: TerrainGridSlot = null

## 放置动画 tween
var _place_tween: Tween = null

## hover 动画 tween
var _hover_tween: Tween = null

## 脉冲动画 tween
var _pulse_tween: Tween = null

## 当前地块数据缓存
var _tile_data: TileBlockData = null

## ============================================================================
## Godot 生命周期
## ============================================================================

func _ready() -> void:
	_setup_empty_slot_style()
	_setup_add_icon()
	if _icon:
		_icon.pivot_offset = _icon.size / 2.0
	# 连接虚线边框绘制
	if _dashed_border:
		_dashed_border.draw.connect(_on_dashed_border_draw)
		_dashed_border.queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_on_mouse_enter()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_on_mouse_exit()
	elif what == NOTIFICATION_DRAG_END:
		_clear_drag_highlight()


## ============================================================================
## 公共方法
## ============================================================================

## 设置网格位置
func set_grid_position(row: int, col: int) -> void:
	grid_row = row
	grid_col = col


## 获取网格行
func get_grid_row() -> int:
	return grid_row


## 获取网格列
func get_grid_col() -> int:
	return grid_col


## 设置地形
func set_terrain(tile_type: int) -> void:
	_current_terrain = tile_type
	_update_icon()


## 获取当前地形
func get_terrain() -> int:
	return _current_terrain


## 清除地形
func clear_terrain() -> void:
	set_terrain(-1)


## 设置选中状态
func set_selected(selected: bool) -> void:
	if is_selected == selected:
		return
	is_selected = selected
	_update_visual_state()


## 获取选中状态
func get_selected() -> bool:
	return is_selected


## 播放放置动画
func play_place_animation() -> void:
	if _place_tween and _place_tween.is_valid():
		_place_tween.kill()

	_place_tween = create_tween()
	_place_tween.set_parallel(false)

	# 从小到大的弹性动画
	_icon.scale = Vector2.ZERO
	_place_tween.tween_property(_icon, "scale", Vector2(1.1, 1.1), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_place_tween.tween_property(_icon, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

	# 发光效果
	_play_glow_effect()

	# 开始脉冲动画
	_start_pulse_animation()


## 播放清除动画
func play_clear_animation() -> void:
	if _place_tween and _place_tween.is_valid():
		_place_tween.kill()
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()

	_place_tween = create_tween()
	_place_tween.set_parallel(true)

	# 淡出
	_place_tween.tween_property(_icon, "modulate:a", 0.0, 0.15)
	_place_tween.tween_property(_icon, "scale", Vector2.ZERO, 0.15)


## ============================================================================
## 拖拽功能
## ============================================================================

## 是否可以接收拖拽数据
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.has("tile_type"):
		_clear_drag_highlight()
		_show_drag_highlight()
		return true
	return false


## 处理拖拽数据
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_hide_drag_highlight()
	if data is Dictionary and data.has("tile_type"):
		drop_data_received.emit(self, data)


## 获取拖拽数据
func _get_drag_data(_at_position: Vector2) -> Variant:
	# 只有已放置地形的槽位才能拖拽
	if _current_terrain < 0:
		return null

	# 创建拖拽数据
	var drag_data: Dictionary = {
		"source": self,
		"source_type": "grid_slot",
		"tile_type": _current_terrain as TileConstants.TileType,
		"from_row": grid_row,
		"from_col": grid_col,
	}

	# 创建拖拽预览
	var preview := _create_drag_preview()
	set_drag_preview(preview)

	return drag_data


## 创建拖拽预览
func _create_drag_preview() -> Control:
	var container := Control.new()
	container.custom_minimum_size = Vector2(80, 80)
	container.z_index = 1000

	# 背景
	var bg := Panel.new()
	bg.custom_minimum_size = Vector2(80, 80)
	container.add_child(bg)

	# 边框样式 - 使用地形专属色
	var style := StyleBoxFlat.new()
	if _tile_data:
		var glow_color := _UIColorUtils.calculate_glow_color(_tile_data.main_color, 0.4)
		style.bg_color = _UIColorUtils.calculate_bg_color(_tile_data.main_color, 0.4, 0.9)
		style.border_color = _tile_data.main_color
		style.shadow_color = glow_color
		style.shadow_size = 8
	else:
		style.bg_color = Color(0.87, 0.7, 0.16, 0.2)
		style.border_color = Color(0.87, 0.7, 0.16, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	bg.add_theme_stylebox_override("panel", style)

	# 图标
	if _icon.texture:
		var icon_rect := TextureRect.new()
		icon_rect.texture = _icon.texture
		icon_rect.custom_minimum_size = Vector2(68, 68)
		icon_rect.position = Vector2(6, 6)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if _tile_data:
			icon_rect.modulate = _tile_data.main_color
		container.add_child(icon_rect)

	return container


## ============================================================================
## 内部方法
## ============================================================================

## 设置空槽位样式
func _setup_empty_slot_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = EMPTY_BG_COLOR
	style.set_border_width_all(0)  # 不用实线边框，用虚线
	style.set_corner_radius_all(4)
	add_theme_stylebox_override("panel", style)


## 设置加号图标
func _setup_add_icon() -> void:
	if _add_icon:
		# 加载加号图标
		var add_texture := load("res://Assets/Icons/UI/add.svg")
		if add_texture:
			_add_icon.texture = add_texture
		_add_icon.visible = false


## 更新图标显示
func _update_icon() -> void:
	if _current_terrain < 0:
		_icon.texture = null
		_icon.modulate = Color.TRANSPARENT
		_tile_data = null
		_stop_pulse_animation()
		_setup_empty_slot_style()
		if _dashed_border:
			_dashed_border.visible = true
			_dashed_border.queue_redraw()
	else:
		var type: TileConstants.TileType = _current_terrain as TileConstants.TileType
		_tile_data = _get_tile_data_for_type(type)
		if _tile_data:
			# 优先使用 SVG 图标
			if not _tile_data.icon_path.is_empty():
				_icon.texture = load(_tile_data.icon_path)
			elif _tile_data.texture:
				_icon.texture = _tile_data.texture
			_icon.modulate = _tile_data.main_color
		if _dashed_border:
			_dashed_border.visible = false
	_update_visual_state()


## 获取地块数据
func _get_tile_data_for_type(type: TileConstants.TileType) -> TileBlockData:
	return tileDatabase.get_tile_data(type)


## 更新视觉状态（根据选中、悬停、拖拽高亮状态）
func _update_visual_state() -> void:
	if _current_terrain < 0:
		# 空槽位状态
		_update_empty_slot_visual()
		return

	if not _tile_data:
		return

	var final_border_color: Color
	var final_icon_color: Color
	var glow_enabled: bool = false
	var glow_color := Color.TRANSPARENT

	# 优先级：选中 > 拖拽 > 悬停 > 默认
	if is_selected:
		final_border_color = _tile_data.accent_color
		final_icon_color = _tile_data.accent_color
		glow_enabled = true
		glow_color = _UIColorUtils.calculate_glow_color(_tile_data.accent_color, 0.4)
	elif is_drag_highlighted:
		final_border_color = DRAG_HIGHLIGHT_COLOR
		final_icon_color = _tile_data.main_color
		glow_enabled = true
		glow_color = _UIColorUtils.calculate_glow_color(DRAG_HIGHLIGHT_COLOR, 0.5)
	elif _is_hovering:
		final_border_color = _tile_data.hover_color
		final_icon_color = _tile_data.main_color
		glow_enabled = true
		glow_color = _UIColorUtils.calculate_glow_color(_tile_data.main_color, 0.3)
	else:
		final_border_color = _tile_data.border_color
		final_icon_color = _tile_data.main_color
		glow_enabled = true
		glow_color = _UIColorUtils.calculate_glow_color(_tile_data.main_color, 0.2)

	_apply_terrain_style(final_border_color, final_icon_color, glow_enabled, glow_color)


## 更新空槽位视觉状态
func _update_empty_slot_visual() -> void:
	var style := StyleBoxFlat.new()

	if is_drag_highlighted:
		style.bg_color = EMPTY_HOVER_BG_COLOR
		style.set_border_width_all(2)
		style.border_color = DRAG_HIGHLIGHT_COLOR
		style.shadow_color = _UIColorUtils.calculate_glow_color(DRAG_HIGHLIGHT_COLOR, 0.3)
		style.shadow_size = 6
	elif _is_hovering:
		style.bg_color = EMPTY_HOVER_BG_COLOR
		style.set_border_width_all(0)
		if _add_icon:
			_add_icon.visible = true
	else:
		style.bg_color = EMPTY_BG_COLOR
		style.set_border_width_all(0)
		if _add_icon:
			_add_icon.visible = false

	style.set_corner_radius_all(4)
	add_theme_stylebox_override("panel", style)

	if _dashed_border:
		_dashed_border.queue_redraw()


## 应用地形样式
func _apply_terrain_style(border_color: Color, icon_color: Color, glow_enabled: bool, glow_color: Color) -> void:
	var style := StyleBoxFlat.new()

	# 使用地形专属背景色
	if _tile_data:
		style.bg_color = _UIColorUtils.calculate_bg_color(_tile_data.main_color, 0.4, 0.6)
	else:
		style.bg_color = Color(0.1, 0.12, 0.16, 0.6)

	style.set_border_width_all(2)
	style.border_color = border_color
	style.set_corner_radius_all(4)

	if glow_enabled:
		style.shadow_color = glow_color
		style.shadow_size = 8
		style.shadow_offset = Vector2.ZERO

	add_theme_stylebox_override("panel", style)

	if _icon:
		_icon.modulate = icon_color


## 显示拖拽高亮
func _show_drag_highlight() -> void:
	if is_drag_highlighted:
		return
	is_drag_highlighted = true
	_current_drag_highlighted = self
	_update_visual_state()


## 隐藏拖拽高亮
func _hide_drag_highlight() -> void:
	if not is_drag_highlighted:
		return
	is_drag_highlighted = false
	_update_visual_state()


## 清除全局拖拽高亮
static func _clear_drag_highlight() -> void:
	if _current_drag_highlighted:
		_current_drag_highlighted._hide_drag_highlight()
		_current_drag_highlighted = null


## 鼠标进入
func _on_mouse_enter() -> void:
	_is_hovering = true
	_update_visual_state()
	_play_hover_animation()


## 鼠标离开
func _on_mouse_exit() -> void:
	_is_hovering = false
	_update_visual_state()
	_play_hover_exit_animation()


## 播放 hover 进入动画
func _play_hover_animation() -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()

	if _current_terrain >= 0:
		_hover_tween = create_tween()
		_hover_tween.set_ease(Tween.EASE_OUT)
		_hover_tween.set_trans(Tween.TRANS_CUBIC)
		_hover_tween.tween_property(self, "modulate", Color(1.1, 1.1, 1.1), 0.2)


## 播放 hover 退出动画
func _play_hover_exit_animation() -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()

	_hover_tween = create_tween()
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.set_trans(Tween.TRANS_CUBIC)
	_hover_tween.tween_property(self, "modulate", Color.WHITE, 0.2)


## 播放发光效果
func _play_glow_effect() -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	# 闪烁发光效果
	tween.tween_method(_set_glow_intensity, 0.0, 1.0, 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_glow_intensity, 1.0, 0.3, 0.2).set_ease(Tween.EASE_IN).set_delay(0.15)


## 设置发光强度
func _set_glow_intensity(intensity: float) -> void:
	var style := get_theme_stylebox("panel") as StyleBoxFlat
	if style is StyleBoxFlat:
		var new_style := style.duplicate() as StyleBoxFlat
		if _tile_data:
			new_style.shadow_color = _UIColorUtils.calculate_glow_color(_tile_data.main_color, intensity * 0.5)
		else:
			new_style.shadow_color = Color(0.87, 0.7, 0.16, intensity * 0.4)
		new_style.shadow_size = int(6 + intensity * 6)
		add_theme_stylebox_override("panel", new_style)


## 开始脉冲动画
func _start_pulse_animation() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()

	_pulse_tween = create_tween()
	_pulse_tween.set_loops()

	# 图标透明度脉冲
	_pulse_tween.tween_property(_icon, "modulate:a", 0.85, 0.75).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(_icon, "modulate:a", 1.0, 0.75).set_ease(Tween.EASE_IN_OUT)


## 停止脉冲动画
func _stop_pulse_animation() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
		_pulse_tween = null


## 虚线边框绘制回调
func _on_dashed_border_draw() -> void:
	if not _dashed_border or _current_terrain >= 0:
		return

	var rect := _dashed_border.get_rect()
	var color := DASHED_BORDER_HOVER_COLOR if _is_hovering else DASHED_BORDER_COLOR
	var dash_length := 6.0
	var gap_length := 4.0
	var line_width := 2.0

	_draw_dashed_rect(_dashed_border, rect, color, dash_length, gap_length, line_width)


## 绘制虚线矩形
func _draw_dashed_rect(canvas: Control, rect: Rect2, color: Color, dash: float, gap: float, width: float) -> void:
	var offset := 2.0  # 内边距
	var x1 := offset
	var y1 := offset
	var x2 := rect.size.x - offset
	var y2 := rect.size.y - offset

	# 上边
	_draw_dashed_line(canvas, Vector2(x1, y1), Vector2(x2, y1), color, dash, gap, width)
	# 右边
	_draw_dashed_line(canvas, Vector2(x2, y1), Vector2(x2, y2), color, dash, gap, width)
	# 下边
	_draw_dashed_line(canvas, Vector2(x2, y2), Vector2(x1, y2), color, dash, gap, width)
	# 左边
	_draw_dashed_line(canvas, Vector2(x1, y2), Vector2(x1, y1), color, dash, gap, width)


## 绘制虚线
func _draw_dashed_line(canvas: Control, from: Vector2, to: Vector2, color: Color, dash: float, gap: float, width: float) -> void:
	var direction := (to - from).normalized()
	var length := from.distance_to(to)
	var current := 0.0

	while current < length:
		var dash_end := minf(current + dash, length)
		var start_pos := from + direction * current
		var end_pos := from + direction * dash_end
		canvas.draw_line(start_pos, end_pos, color, width)
		current = dash_end + gap
