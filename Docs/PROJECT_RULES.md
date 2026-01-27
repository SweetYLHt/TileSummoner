# TileSummoner - 项目规则汇总

本文档汇总了项目开发中需要遵循的所有规则和标准。

## 快速参考

| 文档 | 用途 |
|------|------|
| `CLAUDE.md` | AI 开发上下文配置（主入口） |
| `CODING_STANDARDS.md` | 完整 GDScript 编码标准 |
| `PROJECT_RULES.md` | 本文档 - 规则汇总 |

## 代码组织规则

### 文件大小
- 推荐：200-400 行
- 上限：800 行
- 超过限制：拆分为多个文件

### 目录结构
```
Scripts/
├── <功能模块>/        # 按功能组织，不按类型
│   ├── <模块名>.gd    # 主类（带 class_name）
│   └── <子模块>/      # 相关子功能
```

### 一文件一类
- 每个 `.gd` 文件只有一个 `extends` 语句
- 每个 `.gd` 文件只有一个 `class_name` 声明
- 文件名与类名保持一致

## 命名规范

| 类型 | 格式 | 示例 |
|------|------|------|
| 类名 | `PascalCase` | `class_name TileManager` |
| 函数 | `snake_case` | `func get_tile_data()` |
| 变量 | `snake_case` | `var grid_position` |
| 常量 | `UPPER_SNAKE_CASE` | `const MAX_UNITS = 8` |
| 私有成员 | 前缀 `_` | `var _cached_data` |
| 信号 | `snake_case` | `signal tile_changed` |
| 资源 | `PascalCase` + 后缀 | `TileData.tres` |
| 场景 | `snake_case` | `tile.tscn` |

## 类型注解规则

### 必须注解的情况
- 所有函数参数
- 所有函数返回值
- 所有类成员变量（使用 `@export` 时）

```gdscript
# ✅ 正确
func get_tile(cell: Vector2i) -> TileData:
    return _grid_data[cell.x][cell.y]

# ❌ 错误
func get_tile(cell):
    return _grid_data[cell.x][cell.y]
```

### 可选类型
```gdscript
var optional_data: TileData = null
func get_or_null() -> Variant:
    return null
```

## Godot 特定规则

### StringName 使用
用于频繁比较的字符串 ID：

```gdscript
var tile_type: StringName = &"forest"

# ✅ 使用 StringName
if TileDatabase.has_type(&"forest"):
    pass

# ❌ 避免使用 String
if tile_type == "forest":
    pass
```

### AutoLoad 单例
- 继承 `Node`，无需 `class_name`
- 全局访问，无需 `static`
- 用于全局状态和工具类

```gdscript
# AutoLoad 脚本
extends Node

func register_tile(data: TileData) -> void:
    pass

# 使用
TileDatabase.register_tile(data)
```

### 资源路径
始终使用 `res://` 绝对路径：

```gdscript
const TILE_SCENE = "res://scenes/tile.tscn"
var texture = preload("res://assets/sprite.png")
```

### 内存管理
```gdscript
# ✅ 安全的延迟释放
node.queue_free()

# ❌ 危险的立即释放
node.free()
```

### 信号连接
```gdscript
# 连接前检查
if not signal.is_connected(_on_event):
    signal.connect(_on_event)

# 断开时检查
if signal.is_connected(_on_event):
    signal.disconnect(_on_event)
```

## 注释标准

### 文件头注释
```gdscript
## 地块管理器 - 处理地块创建和连通性检测
##
## 使用示例：
##   var manager = TileManager.new()
##   manager.initialize(grid_size)
##   manager.set_tile(cell, tile_type)
extends Node
class_name TileManager
```

### 函数注释
```gdscript
## 设置指定位置的地块类型
##
## @param cell: 网格坐标
## @param tile_type: 地形类型 ID
## @return: 操作是否成功
func set_tile(cell: Vector2i, tile_type: StringName) -> bool:
    pass
```

### 内联注释
```gdscript
# 复杂逻辑需要解释
for neighbor in _get_neighbors(cell):
    # 只检查已激活的地块
    if neighbor.is_active:
        _check_connectivity(neighbor)
```

## 数据驱动原则

### 使用资源文件
```gdscript
# ❌ 硬编码
var health = 100
var defense = 20
var movement_range = 3

# ✅ 从资源加载
@export var data: TileData
var health = data.base_health
var defense = data.base_defense
var movement_range = data.movement_range
```

### 资源文件位置
```
Resources/
├── Tiles/          # 地块数据
│   ├── grassland.tres
│   ├── forest.tres
│   └── ...
├── Units/          # 单位数据
├── Cards/          # 卡牌数据
└── data/           # 其他配置
```

## 性能优化指南

| 场景 | 优化方案 |
|------|----------|
| 字符串 ID | 使用 `StringName` 而非 `String` |
| 频繁创建对象 | 使用对象池 |
| 数据容器 | 使用 `RefCounted` 而非 `Node` |
| 批量操作 | 合并同一帧的操作 |
| 大资源加载 | 使用 `load()` 而非 `preload()` |

## 工厂模式

### 标准工厂
```gdscript
extends Node
class_name UnitFactory

const BASE_SCENE: PackedScene = preload("res://scenes/unit/unit.tscn")

static func create(data: UnitData, pos: Vector2i) -> Unit:
    if not data:
        push_error("UnitData is null")
        return null

    var unit = BASE_SCENE.instantiate()
    unit.data = data
    unit.grid_position = pos
    return unit
```

## 消息系统

### 发送消息
```gdscript
var msg = TileChangedMessage.new()
msg.cell = Vector2i(3, 4)
msg.new_type = &"forest"
MessageServer.send_message(msg)
```

### 接收消息
```gdscript
func _ready() -> void:
    MessageServer.message_sent.connect(_on_message)

func _on_message(msg: Message) -> void:
    if msg is TileChangedMessage:
        _handle_tile_change(msg)
```

### 可用消息类型
位置：`Scripts/message/messages/`

- `TileChangedMessage` - 地块变化
- `UnitSpawnedMessage` - 单位生成
- `UnitMovedMessage` - 单位移动
- `CardPlayedMessage` - 卡牌使用
- `CombatMessage` - 战斗事件
- ... 等 19 种类型

## 错误处理

### 参数验证
```gdscript
func spawn_unit(data: UnitData, pos: Vector2i) -> Unit:
    # 参数验证
    if not data:
        push_error("UnitData is null")
        return null

    if not _is_valid_position(pos):
        push_error("Invalid position: %s" % pos)
        return null

    # 执行逻辑
    var unit = UnitFactory.create(data, pos)
    if not unit:
        push_error("Failed to create unit")
        return null

    add_child(unit)
    return unit
```

### 调试输出
```gdscript
# 普通信息
print("[Manager] Creating tile at: %s" % pos)

# 警告
push_warning("Type '%s' not found in database" % type_id)

# 错误
push_error("Failed to load texture: %s" % path)
```

## Git 提交规范

### 提交格式
```
<类型>: <简短描述>

<详细描述（可选）>

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 类型说明
| 类型 | 用途 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: add forest terrain` |
| `fix` | Bug 修复 | `fix: connectivity check` |
| `refactor` | 重构 | `refactor: simplify manager` |
| `docs` | 文档 | `docs: update standards` |
| `style` | 格式 | `style: format code` |
| `perf` | 性能 | `perf: optimize rendering` |
| `test` | 测试 | `test: add unit tests` |
| `chore` | 构建/工具 | `chore: update deps` |

### 示例
```
feat: add terrain type selection UI

Implement terrain configuration panel that allows:
- Select terrain type from dropdown
- View and edit terrain properties
- Save changes to .tres resource files

Co-Authored-By: Claude <noreply@anthropic.com>
```

## 测试规则

### TDD 流程
1. 使用 `/tdd` 技能启动测试驱动开发
2. 先写测试用例
3. 实现功能使测试通过
4. 重构优化

### 测试文件位置
```
Scripts/test/
├── test_<模块名>.gd
```

### 测试场景位置
```
Scenes/test/
├── test_<功能名>.tscn
```

### GdUnit4 使用
```bash
# 运行所有测试
.\addons\gdunit4\run_cmd.bat

# 运行特定测试
.\addons\gdunit4\run_cmd.bat --test Scripts/test/test_tile_system.gd
```

## 常见模式

### 单例模式
```gdscript
# AutoLoad 配置
extends Node

var _instance: TileDatabase

func get_instance() -> TileDatabase:
    return self
```

### 观察者模式
```gdscript
# 使用信号实现
signal tile_changed(cell: Vector2i, new_type: StringName)

func _notify_tile_changed(cell: Vector2i, new_type: StringName) -> void:
    tile_changed.emit(cell, new_type)
```

### 状态机
```gdscript
enum State {
    IDLE,
    MOVING,
    ATTACKING,
    DEAD
}

var _current_state: State = State.IDLE

func change_state(new_state: State) -> void:
    _exit_state(_current_state)
    _current_state = new_state
    _enter_state(new_state)
```

## 禁止事项

1. **禁止使用表情符号**：代码、注释、文档中不使用 emoji
2. **禁止硬编码数据**：游戏数据应存储在 .tres 资源文件
3. **禁止直接调用 free()**：使用 queue_free() 代替
4. **禁止未经验证的参数**：函数入口必须验证参数
5. **禁止信号重复连接**：连接前检查 is_connected()
6. **禁止跨模块直接依赖**：使用消息系统解耦
7. **禁止超大文件**：单文件不超过 800 行
8. **禁止缺少类型注解**：所有函数必须有类型注解
