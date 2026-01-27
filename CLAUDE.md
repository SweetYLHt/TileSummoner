# TileSummoner - AI Development Context

## Project Overview

地块召唤师是一款基于 Godot 4.5.1 引擎的策略卡牌游戏，使用 GDScript 开发。玩家通过卡牌召唤地块，构建连通路径来召唤单位，最终击败对手。

## Critical Rules

### 1. 代码组织

- **小文件优先**：单文件 200-400 行，最多 800 行
- **高内聚低耦合**：按功能/领域组织，不按类型
- **一文件一类**：每个 .gd 文件只有一个 extends 和 class_name
- **数据驱动**：使用 .tres 资源文件存储游戏数据

### 2. 代码风格

- **无表情符号**：代码、注释、文档中不使用 emoji
- **类型注解**：所有函数必须有明确的参数和返回类型
- **命名规范**：
  - 类名：`PascalCase` + `class_name`
  - 函数/变量：`snake_case`
  - 常量：`UPPER_SNAKE_CASE`
  - 私有成员：前缀 `_`
  - 信号：`snake_case`
- **StringName**：频繁比较的字符串 ID 必须使用 `StringName`
- **资源路径**：始终使用 `res://` 绝对路径

### 3. 测试与调试

- **TDD 流程**：使用 `/godot-tdd-workflow ` 技能进行测试驱动开发
- **单元测试**：在修改功能时必须查看并修改对应的GDunit4单元测试
- **场景测试**：在 `Scenes/test/` 下创建可视化测试场景
- **调试输出**：
  - 普通：`print("[Manager] Message")`
  - 警告：`push_warning("Warning message")`
  - 错误：`push_error("Error message")`

### 4. Godot 最佳实践

- **内存管理**：使用 `queue_free()` 而非 `free()`
- **信号连接**：连接前检查 `is_connected()`
- **空值检查**：函数入口验证参数是否为 null
- **AutoLoad 单例**：无需 class_name，全局直接访问
- **对象池**：频繁创建的对象使用对象池模式

### 5. 消息系统

- **统一消息路由**：通过 `MessageServer` 发送所有游戏事件
- **解耦通信**：模块间通过消息通信，避免直接依赖
- **消息类型**：使用 `Scripts/message/messages/` 下的 19 种消息类型

## Directory Structure

```
TileSummoner/
├── Docs/                    # 项目文档
│   ├── game_design/        # 游戏设计文档 (13个)
│   └── CODING_STANDARDS.md # 详细编码标准
├── Scenes/                  # 场景文件 (.tscn)
│   ├── tile/               # 地块场景
│   ├── unit/               # 单位场景
│   ├── ui/                 # UI场景
│   └── test/               # 测试场景
├── Scripts/                 # 脚本文件 (.gd)
│   ├── message/            # 消息系统 (已实现)
│   │   ├── message_server.gd
│   │   └── messages/       # 19种消息类型
│   ├── tile/               # 地块系统
│   ├── unit/               # 单位系统
│   ├── ui/                 # UI脚本
│   └── scene/              # 场景管理
├── Resources/               # 资源文件
│   ├── Tiles/              # 地块数据 (.tres)
│   ├── Units/              # 单位数据 (.tres)
│   ├── Cards/              # 卡牌数据 (.tres)
│   └── data/               # 其他游戏数据
└── Assets/                  # 美术资源
    ├── Icons/              # 图标
    ├── Sprites/            # 精灵图
    └── Audio/              # 音频
```

## Project Status

| 模块 | 状态 |
|------|------|
| 设计文档 | 完成 (13个) |
| 消息系统 | 已实现 |
| 地块系统 | 开发中 |
| 地形配置 | 开发中 |
| 单位系统 | 未开始 |
| 经济系统 | 未开始 |
| 战斗系统 | 未开始 |
| UI系统 | 开发中 |

## Quick Start

- **引擎版本**：Godot 4.5.1
- **主场景**：`res://Scenes/main_menu.tscn`
- **AutoLoad 单例**：
  - `MessageServer` - 消息路由中心
  - `TileDatabase` - 地块数据注册表
  - `TerrainConfig` - 地形配置管理

## Key Patterns

### 工厂模式

```gdscript
extends Node
class_name UnitFactory

static func create(data: UnitData, pos: Vector2i) -> Unit:
    if not data:
        push_error("UnitData is null")
        return null
    var unit = BASE_SCENE.instantiate()
    unit.data = data
    unit.grid_position = pos
    return unit
```

### 数据驱动

```gdscript
# ❌ 硬编码
var health = 100
var defense = 20

# ✅ 从资源加载
@export var data: TileData
var health = data.base_health
var defense = data.base_defense
```

### 消息通信

```gdscript
# 发送消息
var msg = TileChangedMessage.new()
msg.cell = Vector2i(3, 4)
msg.new_type = &"forest"
MessageServer.send_message(msg)

# 接收消息
func _ready() -> void:
    MessageServer.message_sent.connect(_on_message)

func _on_message(msg: Message) -> void:
    if msg is TileChangedMessage:
        _handle_tile_change(msg)
```

### 错误处理

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

## Available Commands

| 命令 | 用途 |
|------|------|
| `/godot-tdd-workflow` | 测试驱动开发工作流 (GdUnit4) |
| `/plan` | 创建实现计划 |
| `/code-review` | 代码质量审查 |
| `/commit` | 创建 Git 提交 |

## Tool Preferences (MCP 优先级)

| MCP | 用途 |
|-----|------|
| **Godot MCP** | 项目信息、场景操作、运行游戏 |
| Godot MCP ultimate | 自动化测试、代码校验 |
| **Serena MCP** | 代码结构、符号搜索、文件导航 |

## Git Workflow

- **提交格式**：遵循 Conventional Commits
  - `feat`: 新功能
  - `fix`: Bug 修复
  - `refactor`: 重构
  - `docs`: 文档
  - `style`: 代码格式
  - `perf`: 性能优化
  - `test`: 测试
  - `chore`: 构建/工具

- **分支规则**：
  - 不直接提交到 main
  - PR 需要审查
  - 提交前确保测试通过

## Related Documentation

| 文档 | 用途 |
|------|------|
| `Docs/CODING_STANDARDS.md` | 完整 GDScript 编码标准 |
| `Docs/game_design/*.md` | 游戏设计文档 (13个) |
| `Docs/游戏创意记录——地块召唤师.md` | 核心设计概念 |

## AI Usage Guidelines

1. **阅读设计文档**：实现功能前先阅读 `Docs/game_design/`
2. **使用 Godot MCP**：项目操作优先使用 Godot MCP 工具
3. **遵循编码标准**：所有代码必须符合 `Docs/CODING_STANDARDS.md`
4. **消息系统优先**：模块间通信使用 MessageServer
5. **数据驱动设计**：游戏数据存储在 .tres 资源文件中

## Current Implementation

### 已实现模块

**消息系统** (`Scripts/message/`)
- MessageServer - 全局消息路由单例
- 19 种消息类型 - Tile, Unit, Card, Combat, Base, Flow, Economy, Zone 事件

### 开发中模块

**地块系统** (`Scripts/tile/`)
- Tile - 地块节点脚本
- TileBlockData - 地块数据容器
- TileDatabase - 地块注册表

**地形配置** (`Scenes/ui/terrain_config/`)
- 地形类型选择 UI
- 地形属性配置界面

### 待实现模块

1. **单位系统** - 召唤、移动、AI
2. **经济系统** - 法力值、金币管理
3. **战斗系统** - 攻击、技能、胜负判定
4. **卡牌系统** - 卡组管理、抽卡、出牌
5. **连通算法** - 路径检测、地块连接判定
