extends Node
class_name TileInventory

## 库存数据：Dictionary[StringName, int]
var _inventory: Dictionary = {}


## 添加地块
func add_tile(tile_type: StringName, amount: int = 1) -> void:
	if not _inventory.has(tile_type):
		_inventory[tile_type] = 0
	_inventory[tile_type] += amount


## 消耗地块
func consume_tile(tile_type: StringName, amount: int = 1) -> bool:
	if not _inventory.has(tile_type) or _inventory[tile_type] < amount:
		return false
	_inventory[tile_type] -= amount
	if _inventory[tile_type] <= 0:
		_inventory.erase(tile_type)
	return true


## 获取数量
func get_count(tile_type: StringName) -> int:
	return _inventory.get(tile_type, 0)


## 获取所有类型
func get_all_types() -> Array[StringName]:
	return _inventory.keys()


## 初始化默认库存
func initialize_default_inventory() -> void:
	_inventory.clear()
	add_tile(&"grassland", 20)
	add_tile(&"water", 10)
	add_tile(&"sand", 10)
	add_tile(&"rock", 5)
	add_tile(&"forest", 5)
	add_tile(&"farmland", 5)
	add_tile(&"lava", 2)
	add_tile(&"swamp", 2)
	add_tile(&"ice", 2)


## 清空库存
func clear() -> void:
	_inventory.clear()


## 获取总地块数
func get_total_count() -> int:
	var total := 0
	for count in _inventory.values():
		total += count
	return total
