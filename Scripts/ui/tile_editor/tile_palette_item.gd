## 地形选择按钮组件
##
## 用于地形编辑界面的地形选择列表项
extends Button
class_name TilePaletteItem

## 地形类型（使用 -1 表示未设置）
var tile_type: int = -1

## 子节点引用
@onready var _icon: TextureRect = $HBox/Icon
@onready var _name_label: Label = $HBox/NameLabel
@onready var _count_label: Label = $HBox/CountLabel

## 库存引用（外部设置）
var _inventory: TileInventory = null


func _ready() -> void:
	_update_display()


## 设置数据
func setup(type: TileConstants.TileType, inventory: TileInventory) -> void:
	tile_type = type
	_inventory = inventory
	if is_inside_tree():
		_update_display()


## 更新显示
func _update_display() -> void:
	if tile_type < 0 or not is_inside_tree():
		return

	var type: TileConstants.TileType = tile_type as TileConstants.TileType
	var data: TileBlockData = tileDatabase.get_tile_data(type)
	if data:
		_icon.texture = data.texture
		_name_label.text = data.display_name

	update_count()


## 更新数量显示
func update_count() -> void:
	if _inventory and _count_label and tile_type >= 0:
		var type: TileConstants.TileType = tile_type as TileConstants.TileType
		var count := _inventory.get_count(type)
		_count_label.text = "x%d" % count

		# 库存为0时禁用按钮
		disabled = count <= 0


## 设置选中状态
func set_selected(selected: bool) -> void:
	if selected:
		add_theme_stylebox_override("normal", _create_selected_style())
	else:
		remove_theme_stylebox_override("normal")


## 创建选中样式
func _create_selected_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.8, 0.0, 0.3)  # 黄色半透明
	style.border_color = Color.YELLOW
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	return style


## ============ 拖拽功能 ============

## 获取拖拽数据
func _get_drag_data(at_position: Vector2) -> Variant:
	# 库存为0时不允许拖拽
	if not _inventory or tile_type < 0:
		return null

	var type: TileConstants.TileType = tile_type as TileConstants.TileType
	if _inventory.get_count(type) <= 0:
		return null

	# 创建拖拽数据
	var drag_data: Dictionary = {
		"source": "inventory",
		"tile_type": type
	}

	# 创建拖拽预览
	var preview := _create_drag_preview()
	set_drag_preview(preview)

	return drag_data


## 创建拖拽预览
func _create_drag_preview() -> Control:
	var preview := TextureRect.new()
	preview.texture = _icon.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(52, 52)
	preview.modulate = Color(1, 1, 1, 0.8)
	preview.z_index = 1000

	# 添加边框效果
	var container := Panel.new()
	container.add_child(preview)
	preview.position = Vector2(6, 6)
	container.custom_minimum_size = Vector2(64, 64)

	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color.YELLOW
	container.add_theme_stylebox_override("panel", style_box)

	return container
