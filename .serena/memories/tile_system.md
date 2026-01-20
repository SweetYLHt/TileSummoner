# 地块系统实现详情

## 模块概述
地块系统是 TileSummoner 的核心系统之一，负责管理游戏中的地形数据和网格布局。

## 核心组件

### 1. TileData (Scripts/tile/tile_data.gd)
**用途**: 地形数据资源类

**关键属性**:
- `tile_type: StringName` - 地形类型ID
- `display_name: String` - 显示名称
- `category: StringName` - 分类（basic/advanced/special）
- `element_type: StringName` - 元素词条
- `texture: Texture2D` - 地形贴图
- `affinity_matrix: Array[int]` - 8种词条加成数组

**使用方式**: 作为 .tres 资源文件存储在 `Resources/Tiles/`

### 2. TileDatabase (Scripts/tile/tile_database.gd)
**用途**: 全局地形数据库（AutoLoad 单例）

**核心功能**:
- `_load_all_tiles()` - 加载所有地形资源
- `get_tile_data(tile_type)` - 获取地形数据
- `get_all_tile_types()` - 获取所有地形类型
- `is_valid_tile_type(tile_type)` - 验证地形类型

**特点**: 自动加载地形贴图，提供统一查询接口

### 3. Tile (Scripts/tile/tile.gd)
**用途**: 单个地块实例脚本

**关键属性**:
- `_data: TileData` - 地形数据引用
- `grid_position: Vector2i` - 网格坐标
- `is_editable: bool` - 是否可编辑
- `is_selected: bool` - 选中状态

**核心方法**:
- `set_data(data)` - 设置地块数据
- `play_switch_animation()` - 播放切换动画
- `play_spawn_animation(delay)` - 播放入场动画
- `highlight()` / `unhighlight()` - 高亮控制

### 4. GridManager (Scripts/tile/grid_manager.gd)
**用途**: 7×9 网格管理器

**网格布局**:
- 敌方区域: 第0-4行（35格）
- 我方区域: 第5-8行（28格）
- 单元格尺寸: 250×204px
- 单元格偏移: (125, 102)

**核心方法**:
- `create_grid(enemy_config, player_config)` - 创建完整网格
- `clear_grid()` - 清空网格
- `get_tile(cell)` - 获取地块实例
- `replace_tile(cell, new_type)` - 替换地块并发送消息

### 5. BattleMapGenerator (Scripts/tile/battle_map_generator.gd)
**用途**: 战斗地图生成器

**核心功能**:
- 加载玩家和敌方配置
- 拼接敌我区域（35+28=63）
- 播放入场动画（从上到下，每行延迟0.05秒）

**核心方法**:
- `load_player_config(config_name)` - 加载玩家配置
- `load_enemy_config(difficulty)` - 加载敌方配置
- `initialize_battle_map(grid_manager, ...)` - 初始化战斗地图

### 6. TileInventory (Scripts/inventory/tile_inventory.gd)
**用途**: 库存管理器

**数据结构**: `Dictionary[StringName, int]` - 地形类型→数量

**核心方法**:
- `add_tile(type, amount)` - 添加地块
- `consume_tile(type, amount)` - 消耗地块（检查库存）
- `get_count(type)` - 获取数量
- `initialize_default_inventory()` - 初始化默认库存

**默认库存**: 草地×20, 水域×10, 沙地×10, 岩石×5, 森林×5, 农田×5, 熔岩×2, 沼泽×2, 冰原×2

## 配置文件系统

### TileConfig (Scripts/tile/tile_config.gd)
**用途**: 角色配置资源类

**属性**:
- `config_name: StringName` - 配置名称
- `config_type: StringName` - 配置类型（player/enemy）
- `tiles: Array[StringName]` - 扁平化存储的地形数组

**方法**:
- `get_tile_at(index)` - 获取指定索引的地形
- `get_config()` - 获取完整配置数组
- `get_size()` - 获取配置大小

### 配置文件位置
`Resources/Tiles/Configs/`

**可用配置**:
- `player_default.tres` - 默认玩家配置（28格）
- `enemy_easy.tres` - 简单敌方（35格，全草地）
- `enemy_medium.tres` - 中等敌方（35格，多种地形）
- `enemy_hard.tres` - 困难敌方（35格，复杂地形）

## 测试系统

### 测试场景
`Scenes/test_tile_system.tscn`

**测试内容**:
1. TileDatabase 加载测试（9种地形）
2. 配置文件加载测试（玩家28格+敌方35格）
3. 地图生成测试（63个地块）
4. 坐标计算验证
5. 入场动画播放

### 运行测试
1. 打开 Godot 编辑器
2. 按 F5 运行项目
3. 观察控制台输出和地图生成

## 消息系统集成

### TileChangedMessage
地块变化时自动发送消息

**发送位置**: `GridManager.replace_tile()`

**消息内容**:
- `cell: Vector2i` - 变化的坐标
- `old_type: StringName` - 旧地形类型
- `new_type: StringName` - 新地形类型

**监听示例**:
```gdscript
func _ready() -> void:
    MessageServer.register_listener(self, _on_tile_changed)

func _on_tile_changed(msg: TileChangedMessage) -> void:
    print("地块 %s 从 %s 变为 %s" % [msg.cell, msg.old_type, msg.new_type])
```

## 动画系统

### 切换动画（编辑界面）
- 缩放: 1 → 0 → 1（0.15s + 0.2s）
- 旋转: 360度（0.35s）
- 缓动: EASE_OUT_BACK + TRANS_SPRING

### 入场动画（战斗地图）
- 起始位置: 原位置上方500px
- 结束位置: 原位置
- 持续时间: 0.5s
- 缓动: EASE_OUT_BOUNCE
- 行延迟: 每行延迟0.05秒

## 文件清单

### 脚本文件（8个）
- `Scripts/tile/tile_data.gd`
- `Scripts/tile/tile_config.gd`
- `Scripts/tile/tile_database.gd`
- `Scripts/tile/tile.gd`
- `Scripts/tile/grid_manager.gd`
- `Scripts/tile/battle_map_generator.gd`
- `Scripts/inventory/tile_inventory.gd`
- `Scripts/test/test_tile_system.gd`

### 资源文件（13个）
- `Resources/Tiles/*.tres`（9个地形资源）
- `Resources/Tiles/Configs/*.tres`（4个配置文件）

### 场景文件（3个）
- `Scenes/tile/tile.tscn`
- `Scenes/battle_map.tscn`
- `Scenes/test_tile_system.tscn`

## 后续扩展方向

### 立即可实现
- 地块编辑器UI（4×7战斗图 + 库存面板）
- 交互系统（鼠标点击、高亮选中）

### 待实现功能
- 单位召唤系统（地块消耗→单位诞生）
- 地块→基石转换（岩石特殊机制）
- 虚空坠毁检测
- 连通性算法（BFS路径检测）
- 断路判负

### 性能优化
- 视锥剔除（仅渲染可见区域）
- 地块合并渲染（相邻相同地形）
- LOD系统（远景简化）
