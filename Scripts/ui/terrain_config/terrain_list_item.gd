## 地形列表项
## 用于显示可用地形列表中的单个地形项，支持拖拽
extends Button
class_name TerrainListItem

## 信号：拖拽开始
signal drag_started(tile_type: TileConstants.TileType)

## ============================================================================
## 预加载
## ============================================================================

const _UIColorUtils := preload("res://Scripts/utils/ui_color_utils.gd")

## ============================================================================
## 节点引用
## ============================================================================

@onready var _icon_container: Panel = $HBox/IconContainer
@onready var _icon: TextureRect = $HBox/IconContainer/Icon
@onready var _name_label: Label = $HBox/NameLabel
@onready var _count_label: Label = $HBox/CountLabel

## ============================================================================
## 内部变量
## ============================================================================

## 地形类型
var _tile_type: TileConstants.TileType = TileConstants.TileType.GRASSLAND

## 可用数量
var _available_count: int = 0

## 是否可以拖拽
var _can_drag: bool = true

## hover 动画 tween
var _hover_tween: Tween = null

## 当前地块数据缓存
var _tile_data: TileBlockData = null

## ============================================================================
## Godot 生命周期
## ============================================================================

func _ready() -> void:
	_update_display()
	if _icon_container:
		_icon_container.pivot_offset = _icon_container.size / 2.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_on_mouse_enter()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_on_mouse_exit()


## ============================================================================
## 公共方法
## ============================================================================

## 设置数据
func setup(tile_type: TileConstants.TileType, count: int) -> void:
	_tile_type = tile_type
	_available_count = count
	if is_inside_tree():
		_update_display()


## 更新数量
func update_count(new_count: int) -> void:
	_available_count = new_count
	_count_label.text = "x%d" % _available_count

	# 数量为0时禁用拖拽
	_can_drag = _available_count > 0
	disabled = not _can_drag

	# 更新视觉状态
	_update_disabled_visual()


## 获取地形类型
func get_tile_type() -> TileConstants.TileType:
	return _tile_type


## ============================================================================
## 拖拽功能
## ============================================================================

## 获取拖拽数据
func _get_drag_data(_at_position: Vector2) -> Variant:
	if not _can_drag:
		return null

	# 创建拖拽数据
	var drag_data: Dictionary = {
		"source": self,
		"source_type": "terrain_list",
		"tile_type": _tile_type
	}

	# 发射信号
	drag_started.emit(_tile_type)

	# 创建拖拽预览
	var preview := _create_drag_preview()
	set_drag_preview(preview)

	return drag_data


## 创建拖拽预览
func _create_drag_preview() -> Control:
	var container := Control.new()
	container.custom_minimum_size = Vector2(120, 50)
	container.z_index = 1000

	# 背景
	var bg := Panel.new()
	bg.custom_minimum_size = Vector2(120, 50)
	container.add_child(bg)

	# 边框样式 - 使用地形专属色
	var style := StyleBoxFlat.new()
	if _tile_data:
		var glow_color := _UIColorUtils.calculate_glow_color(_tile_data.main_color, 0.3)
		style.bg_color = _UIColorUtils.calculate_bg_color(_tile_data.main_color, 0.4, 0.8)
		style.border_color = _tile_data.main_color
		style.shadow_color = glow_color
		style.shadow_size = 6
	else:
		style.bg_color = Color(0.87, 0.7, 0.16, 0.2)
		style.border_color = Color(0.87, 0.7, 0.16, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	bg.add_theme_stylebox_override("panel", style)

	# 内容容器
	var hbox := HBoxContainer.new()
	hbox.position = Vector2(6, 6)
	container.add_child(hbox)

	# 图标
	var icon_rect := TextureRect.new()
	icon_rect.texture = _icon.texture
	icon_rect.custom_minimum_size = Vector2(38, 38)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if _tile_data:
		icon_rect.modulate = _tile_data.main_color
	hbox.add_child(icon_rect)

	# 文本
	var vbox := VBoxContainer.new()
	vbox.position = Vector2(6, 0)
	hbox.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = _name_label.text
	if _tile_data:
		name_lbl.add_theme_color_override("font_color", _tile_data.main_color)
	else:
		name_lbl.add_theme_color_override("font_color", Color(0.87, 0.7, 0.16))
	name_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(name_lbl)

	var count_lbl := Label.new()
	count_lbl.text = _count_label.text
	count_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	count_lbl.add_theme_font_size_override("font_size", 10)
	vbox.add_child(count_lbl)

	return container


## ============================================================================
## 内部方法
## ============================================================================

## 更新显示
func _update_display() -> void:
	# 获取地块数据
	_tile_data = _get_tile_data_for_type(_tile_type)

	if _tile_data:
		# 优先使用 SVG 图标路径
		if not _tile_data.icon_path.is_empty():
			_icon.texture = load(_tile_data.icon_path)
		elif _tile_data.texture:
			_icon.texture = _tile_data.texture
		else:
			_icon.texture = null

		# 应用地形主色到图标
		_icon.modulate = _tile_data.main_color
		_name_label.text = _tile_data.display_name

		# 更新图标容器样式
		_apply_terrain_style_to_icon_container()
	else:
		# 使用默认图标
		_icon.texture = null
		_icon.modulate = Color.WHITE
		_name_label.text = TileConstants.get_tile_type_name(_tile_type)

	_count_label.text = "x%d" % _available_count
	_can_drag = _available_count > 0
	disabled = not _can_drag
	_update_disabled_visual()


## 获取地块数据
func _get_tile_data_for_type(type: TileConstants.TileType) -> TileBlockData:
	return tileDatabase.get_tile_data(type)


## 应用地形样式到图标容器
func _apply_terrain_style_to_icon_container() -> void:
	if not _tile_data or not _icon_container:
		return

	var style := StyleBoxFlat.new()
	var bg_color := _UIColorUtils.calculate_bg_color(_tile_data.main_color)
	var border_color := _UIColorUtils.calculate_icon_border_color(_tile_data.main_color)

	style.bg_color = bg_color
	style.set_border_width_all(2)
	style.border_color = border_color
	style.set_corner_radius_all(8)

	_icon_container.add_theme_stylebox_override("panel", style)


## 更新禁用视觉状态
func _update_disabled_visual() -> void:
	if disabled:
		modulate = Color(0.5, 0.5, 0.5, 0.6)
	else:
		modulate = Color.WHITE


## 鼠标进入
func _on_mouse_enter() -> void:
	if disabled:
		return
	_play_hover_animation()


## 鼠标离开
func _on_mouse_exit() -> void:
	_play_hover_exit_animation()


## 播放 hover 进入动画
func _play_hover_animation() -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()

	_hover_tween = create_tween()
	_hover_tween.set_parallel(true)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.set_trans(Tween.TRANS_SINE)

	# 图标容器放大
	if _icon_container:
		_hover_tween.tween_property(_icon_container, "scale", Vector2(1.1, 1.1), 0.15)

	# 整体变亮
	_hover_tween.tween_property(self, "modulate", Color(1.1, 1.1, 1.1), 0.15)


## 播放 hover 退出动画
func _play_hover_exit_animation() -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()

	_hover_tween = create_tween()
	_hover_tween.set_parallel(true)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.set_trans(Tween.TRANS_SINE)

	# 图标容器恢复
	if _icon_container:
		_hover_tween.tween_property(_icon_container, "scale", Vector2(1.0, 1.0), 0.15)

	# 恢复默认颜色
	if disabled:
		_hover_tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5, 0.6), 0.15)
	else:
		_hover_tween.tween_property(self, "modulate", Color.WHITE, 0.15)
