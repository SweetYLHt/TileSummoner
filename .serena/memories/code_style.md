# 代码风格和约定

## 基本原则
遵循 `Docs/CODING_STANDARDS.md` 中定义的所有规范。

## 类型注解
- **必须**为所有变量、参数、返回值添加类型注解
- 使用 `:=` 进行类型推断
- 数组类型: `Array[Type]` 或 `PackedStringArray`
- 字典类型: `Dictionary[key_type, value_type]`

示例:
```gdscript
var _data: TileData
var _grid: Array[Array] = []
func get_tile(cell: Vector2i) -> Tile:
```

## 命名规范

### 变量命名
- **私有变量**: 下划线前缀 `_data`, `_grid`
- **常量**: 全大写 `GRID_WIDTH`, `CELL_SIZE`
- **普通变量**: 小写+下划线 `tile_type`, `grid_position`
- **StringName**: 使用 `&"name"` 语法 `&"grassland"`

### 函数命名
- **私有函数**: 下划线前缀 `_load_all_tiles()`
- **公共函数**: 小写+下划线 `get_tile_data()`
- **工具函数**: 动词开头 `calculate_position()`

### 类命名
- **PascalCase**: `class_name TileDatabase`

## StringName 优化
- **频繁使用的字符串**: 使用 `StringName` 节省内存
- **固定字符串常量**: 使用 `&"string"` 语法
- **示例**: `tile_type: StringName = &"grassland"`

## 文件组织
1. **类定义和 class_name**: 文件开头
2. **常量定义**: 紧随其后
3. **变量定义**: 按私有→公共顺序
4. **虚函数**: `_ready()`, `_process()`, `_input()`
5. **公共方法**: 按功能分组
6. **私有方法**: 按调用顺序

## 注释规范
- **类注释**: 使用 `##` 描述类的用途
- **函数注释**: 使用 `##` 描述功能、参数、返回值
- **行内注释**: 使用 `#` 说明复杂逻辑
- **示例**:
```gdscript
## 加载所有地形资源
func _load_all_tiles() -> void:
```

## Godot 特定规范
- **路径**: 使用 `res://` 前缀
- **预加载**: 使用 `preload()` 加载常量资源
- **节点引用**: 使用 `@onready` 延迟加载
- **信号连接**: 使用 `connect()` 或匿名函数

## 性能优化
- **避免**: 频繁的字符串拼接
- **推荐**: 使用 `StringName` 和 `PackedStringArray`
- **避免**: 在循环中创建临时对象
- **推荐**: 复用对象或使用对象池
