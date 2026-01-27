# 地形配置 UI - 下一步建议

## 概述

地形配置 UI 已完成基础实现，包括主界面、网格系统、拖拽功能和赛博朋克主题。以下是需要完成的功能增强和集成工作。

---

## 1. 集成地块数据库 🔌

### 问题描述
当前 `_get_tile_data_for_type()` 函数返回 `null`，需要连接现有的地块数据系统。

### 实现步骤

#### 1.1 检查现有地块数据库
```bash
# 查看现有地块数据资源
ls Resources/Tiles/
# grassland.tres, water.tres, forest.tres, etc.
```

#### 1.2 创建地块数据库自动加载
在 `project.godot` 或 `AutoLoad` 中添加：

```gdscript
# Scripts/tile/tile_database.gd
extends Node
class_name TileDatabase

## 地形数据字典 [tile_type -> TileBlockData]
var _tile_data_map: Dictionary = {}

func _ready() -> void:
    _load_all_tile_data()

## 加载所有地形数据
func _load_all_tile_data() -> void:
    var tile_types: Array[TileConstants.TileType] = TileConstants.get_all_tile_types()
    for tile_type: TileConstants.TileType in tile_types:
        var path := _get_tile_path(tile_type)
        var data: TileBlockData = load(path) as TileBlockData
        if data:
            _tile_data_map[tile_type] = data

## 获取地形数据
func get_tile_data(tile_type: TileConstants.TileType) -> TileBlockData:
    if _tile_data_map.has(tile_type):
        return _tile_data_map[tile_type]
    return null

## 获取地形文件路径
func _get_tile_path(tile_type: TileConstants.TileType) -> String:
    match tile_type:
        TileConstants.TileType.GRASSLAND: return "res://Resources/Tiles/grassland.tres"
        TileConstants.TileType.WATER: return "res://Resources/Tiles/water.tres"
        TileConstants.TileType.SAND: return "res://Resources/Tiles/sand.tres"
        TileConstants.TileType.ROCK: return "res://Resources/Tiles/rock.tres"
        TileConstants.TileType.FOREST: return "res://Resources/Tiles/forest.tres"
        TileConstants.TileType.FARMLAND: return "res://Resources/Tiles/farmland.tres"
        TileConstants.TileType.LAVA: return "res://Resources/Tiles/lava.tres"
        TileConstants.TileType.SWAMP: return "res://Resources/Tiles/swamp.tres"
        TileConstants.TileType.ICE: return "res://Resources/Tiles/ice.tres"
    return ""
```

#### 1.3 更新脚本引用
```gdscript
# terrain_grid_slot.gd 和 terrain_list_item.gd
func _get_tile_data_for_type(type: TileConstants.TileType) -> TileBlockData:
    return TileDatabase.get_tile_data(type)
```

---

## 2. 添加地形纹理图标 🎨

### 问题描述
当前 SVG 图标已创建但需要正确导入，每个地形类型需要配置对应的纹理。

### 实现步骤

#### 2.1 创建地形纹理资源
```
Assets/Sprites/Terrains/
├── grassland.png
├── water.png
├── sand.png
├── rock.png
├── forest.png
├── farmland.png
├── lava.png
├── swamp.png
└── ice.png
```

#### 2.2 更新地块数据资源
为每个 `.tres` 文件添加纹理引用：

```gdscript
# Resources/Tiles/grassland.tres
[resource]
script = ExtResource("1_tile_data")
display_name = "草地"
texture = preload("res://Assets/Sprites/Terrains/grassland.png")
# ... 其他属性
```

#### 2.3 设置 SVG 图标导入
对于现有 SVG 图标，在编辑器中：
1. 选择 `Assets/Icons/UI/*.svg`
2. 在导入设置中设置为 "Texture2D"
3. 调整目标尺寸为 64x64

---

## 3. 测试完整流程 ✅

### 测试检查清单

#### 3.1 基础功能测试
- [ ] UI 正常加载，无错误
- [ ] 主题样式正确应用
- [ ] 网格显示 4×7 = 28 个槽位
- [ ] 侧边栏显示 9 种地形类型

#### 3.2 拖拽功能测试
- [ ] 从侧边栏拖拽地形到网格
- [ ] 拖拽预览正确显示
- [ ] 放置后图标正确显示
- [ ] Hover 动画流畅 (向上 -2px)
- [ ] 发光边框效果正常

#### 3.3 交互测试
- [ ] 点击"返回"按钮触发 `back_requested` 信号
- [ ] 点击"开始"按钮触发 `config_completed` 信号
- [ ] 点击"重置"按钮清空所有配置
- [ ] 难度选择正确切换
- [ ] Escape 键返回

#### 3.4 数据验证
```gdscript
# 测试场景脚本
extends Node2D

func _ready() -> void:
    var ui := preload("res://Scenes/ui/terrain_config/terrain_config_ui.tscn").instantiate()
    add_child(ui)
    ui.config_completed.connect(_on_config_done)
    ui.back_requested.connect(_on_back)

func _on_config_done(config: Dictionary) -> void:
    print("配置类型: ", config["config_type"])
    print("网格配置: ", config["grid"])
    # 验证数据结构
    assert(config["grid"].size() == 7)  # 7 行
    assert(config["grid"][0].size() == 4)  # 4 列

func _on_back() -> void:
    print("返回请求")
    queue_free()
```

---

## 4. 音效反馈系统 🔊

### 音效列表

| 事件 | 音效文件 | 建议 |
|------|----------|------|
| 拖拽开始 | `ui_drag_start.ogg` | 短促的"拿起"音 |
| 放置地形 | `tile_place.ogg` | 闷响 + 元素音效 |
| Hover 进入 | `ui_hover.ogg` | 极轻微的"触碰"音 |
| 点击按钮 | `ui_click.ogg` | 清脆的点击音 |
| 重置配置 | `ui_reset.ogg` | 扫除音效 |
| 配置完成 | `ui_complete.ogg` | 成功提示音 |

### 实现代码

```gdscript
# Scripts/ui/terrain_config/terrain_config_audio.gd
extends Node
class_name TerrainConfigAudio

## 音效播放器
@onready var _audio_player := AudioStreamPlayer.new()

## 音效资源
var _sounds: Dictionary = {}

func _ready() -> void:
    add_child(_audio_player)
    _load_sounds()

## 加载音效
func _load_sounds() -> void:
    _sounds = {
        "drag_start": preload("res://Assets/Sounds/ui_drag_start.ogg"),
        "tile_place": preload("res://Assets/Sounds/tile_place.ogg"),
        "hover": preload("res://Assets/Sounds/ui_hover.ogg"),
        "click": preload("res://Assets/Sounds/ui_click.ogg"),
        "reset": preload("res://Assets/Sounds/ui_reset.ogg"),
        "complete": preload("res://Assets/Sounds/ui_complete.ogg"),
    }

## 播放音效
func play(sound_name: String) -> void:
    if _sounds.has(sound_name):
        _audio_player.stream = _sounds[sound_name]
        _audio_player.play()
```

### 集成到 UI

```gdscript
# terrain_config_ui.gd
@onready var _audio := TerrainConfigAudio.new()

func _ready() -> void:
    add_child(_audio)
    # 连接信号...

func _on_slot_drop_data(...) -> void:
    _audio.play("tile_place")
    # ...

func _on_back_pressed() -> void:
    _audio.play("click")
    back_requested.emit()
```

---

## 5. 进阶功能 🚀

### 5.1 配置保存/加载

```gdscript
# Scripts/ui/terrain_config/terrain_config_saver.gd
extends RefCounted
class_name TerrainConfigSaver

## 保存配置到文件
func save_config(config: Dictionary, file_path: String) -> Error:
    var file := FileAccess.open(file_path, FileAccess.WRITE)
    if not file:
        return ERR_CANT_OPEN

    var json_string := JSON.stringify(config)
    file.store_string(json_string)
    file.close()
    return OK

## 从文件加载配置
func load_config(file_path: String) -> Dictionary:
    var file := FileAccess.open(file_path, FileAccess.READ)
    if not file:
        return {}

    var json_string := file.get_as_text()
    file.close()

    var json := JSON.new()
    var error := json.parse(json_string)
    if error != OK:
        return {}

    return json.data
```

### 5.2 难度预设配置

```gdscript
# Scripts/ui/terrain_config/difficulty_presets.gd
extends Resource
class_name DifficultyPresets

## 简单敌人预设
static func get_easy_preset() -> Array:
    return [
        [-1, -1, -1, -1],
        [-1,  4,  4, -1],  # 森林
        [-1,  4,  4, -1],
        [-1, -1, -1, -1],
        [-1, -1, -1, -1],
        [-1, -1, -1, -1],
        [-1, -1, -1, -1],
    ]

## 困难敌人预设
static func get_hard_preset() -> Array:
    return [
        [ 6,  6,  6,  6],  # 熔岩
        [ 6,  8,  8,  6],  # 熔岩 + 冰原
        [ 6,  8,  8,  6],
        [ 6,  6,  6,  6],
        [ 7,  7,  7,  7],  # 沼泽
        [ 7,  3,  3,  7],  # 沼泽 + 岩石
        [ 7,  3,  3,  7],
    ]
```

### 5.3 配置验证规则

```gdscript
# Scripts/ui/terrain_config/config_validator.gd
extends RefCounted
class_name ConfigValidator

## 验证配置是否有效
func validate(config: Dictionary) -> bool:
    if not config.has("grid"):
        return false

    var grid: Array = config["grid"]
    if grid.size() != 7:
        return false

    # 检查每种地形的数量限制
    var tile_counts := _count_tiles(grid)
    for tile_type in tile_counts:
        if tile_counts[tile_type] > _get_max_count(tile_type):
            return false

    return true

## 统计地形数量
func _count_tiles(grid: Array) -> Dictionary:
    var counts := {}
    for row: Array in grid:
        for tile: int in row:
            if tile >= 0:
                counts[tile] = counts.get(tile, 0) + 1
    return counts

## 获取最大数量限制
func _get_max_count(tile_type: int) -> int:
    match tile_type:
        6: return 5  # 熔岩最多 5 个
        8: return 8  # 冰原最多 8 个
        _: return 99
```

---

## 6. 已知问题与修复 🔧

### 6.1 SVG 图标未正确导入
**问题**: Godot 无法直接加载 SVG 作为 Texture2D
**解决**:
1. 使用 `svg_to_png.py` 批量转换
2. 或在编辑器中导入为 Texture2D

### 6.2 整数除法警告
**问题**: `i / grid_columns` 触发警告
**状态**: 已修复，使用 `range(total_slots)` 替代

### 6.3 类型注解警告
**问题**: 自定义类类型未正确识别
**状态**: 已将 `TerrainConfigData` 改为 `Resource` 类型

---

## 7. 性能优化建议 ⚡

### 7.1 场景懒加载
```gdscript
# 使用 preload 改为动态加载
var _grid_slot_scene := load("res://Scenes/ui/terrain_config/terrain_grid_slot.tscn")

func _create_grid_slots() -> void:
    for i in range(total_slots):
        var slot = _grid_slot_scene.instantiate()
        # ...
```

### 7.2 纹理图集
考虑将所有地形图标合并为一张图集，减少 Draw Call。

---

## 8. 文档更新 📚

需要更新以下文档：
- [ ] `CLAUDE.md` - 添加地形配置 UI 说明
- [ ] `Docs/CODING_STANDARDS.md` - UI 编码规范
- [ ] `Docs/game_design/` - 战斗系统设计文档

---

## 优先级排序

| 优先级 | 任务 | 预计时间 |
|--------|------|----------|
| 🔴 高 | 集成地块数据库 | 1-2 小时 |
| 🔴 高 | 添加地形纹理 | 2-3 小时 |
| 🟡 中 | 测试完整流程 | 1 小时 |
| 🟡 中 | 音效反馈系统 | 2-3 小时 |
| 🟢 低 | 配置保存/加载 | 1-2 小时 |
| 🟢 低 | 难度预设配置 | 1 小时 |
| 🟢 低 | 性能优化 | 按需 |

---

*创建日期: 2025-01-22*
*项目: TileSummoner*
*作者: Claude Code*
