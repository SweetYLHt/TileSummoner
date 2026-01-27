# 任务计划：HTML UI 转 Godot 场景

## 任务描述
将 HTML 地形配置 UI 转换为 Godot UI 场景，保留原有效果和动效，导入图标资源，使用 GodotMCP 测试。

## 研究阶段分析

### 需求完整性评分：10/10

### HTML UI 核心特性
- **主题**: 赛博朋克深色主题，霓虹金强调色 (#dfb22a)
- **布局**: Header + 左侧边栏(地形列表) + 主区域(4×7网格) + Footer
- **动效**: hover 上浮、发光、脉冲、边框过渡

### 颜色方案
```gdscript
# 主色调
const COLOR_PRIMARY = Color("#dfb22a")
const COLOR_PRIMARY_DIM = Color("#8c6e12")

# 背景
const COLOR_STONE_DARK = Color("#0a0c10")
const COLOR_STONE_LIGHT = Color("#1A1E26")
const COLOR_PANEL_BG = Color("#13161d")
const COLOR_BORDER = Color("#2a303b")

# 地形颜色
const COLOR_GRASS = Color("#10b981")
const COLOR_WATER = Color("#3b82f6")
const COLOR_DESERT = Color("#f59e0b")
const COLOR_ROCK = Color("#78716c")
const COLOR_FOREST = Color("#15803d")
const COLOR_FARM = Color("#ea580c")
const COLOR_LAVA = Color("#ef4444")
const COLOR_SWAMP = Color("#65a30d")
const COLOR_ICE = Color("#06b6d4")
```

### 图标资源
15 个图标文件：grid_view.svg, swords.svg, restart_alt.svg, info.svg, 以及地形图标

### 关键文件
- 源文件: `C:\Users\Administrator\Downloads\stitch_unit_selection_ui_modern_cyber (1)\code.html`
- 图标目录: `C:\Users\Administrator\Downloads\stitch_unit_selection_ui_modern_cyber (1)\icons\`
- 目标项目: `H:\!GameStart\TileSummoner`

## 动效映射

| HTML 动效 | Godot 实现 |
|-----------|------------|
| `translateY(-2px)` | `tween_position` |
| `box-shadow: glow` | `CanvasItemModulate` + `BackBufferCopy` |
| `animate-pulse-slow` | `AnimationPlayer` 循环 |
| `transition: all 0.2s` | `Tween.tween_interval` |

## 推荐方案：方案 C - 混合方案 ⭐

### 核心策略
- 新建独立主场景（避免修改现有代码）
- 复用现有组件脚本逻辑
- 引入主题资源（项目最佳实践升级）
- 数据驱动配置（.tres 资源文件）

---

## 详细执行计划

### 步骤 1：导入图标资源
**文件**: `Assets/Icons/UI/`

| 操作 | 详情 |
|------|------|
| 创建目录 | `Assets/Icons/UI/` |
| 复制图标 | 从 `icons/` 复制 15 个 SVG 文件 |
| 验证导入 | Godot 自动生成 `.import` 文件 |

**验收标准**: 所有图标在编辑器中可预览

---

### 步骤 2：创建主题资源
**文件**: `Resources/ui/cyberpunk_theme.tres`

```gdscript
# 主题内容
extends Theme

# 颜色定义
- Color-primary: #dfb22a
- Color-primary_dim: #8c6e12
- Color-stone_dark: #0a0c10
- Color-stone_light: #1A1E26
- Color-panel_bg: #13161d
- Color-border: #2a303b
- 9种地形颜色

# StyleBox 样式
- Panel (深色背景)
- Button (普通/悬停/按下三种状态)
- LineEdit (输入框样式)
```

**验收标准**: 主题可被 Control 节点加载

---

### 步骤 3：创建地形数据资源
**文件**: `Resources/data/terrain_config_data.tres`

```gdscript
extends Resource
class_name TerrainConfigData

@export var terrain_list: Array[TerrainEntry] = []

## 地形条目
class TerrainEntry:
    extends Resource
    @export var name: StringName
    @export var icon: Texture2D
    @export var color: Color
    @export var count: int
```

**验收标准**: 资源可在编辑器中编辑

---

### 步骤 4：创建主 UI 场景
**文件**: `Scenes/ui/terrain_config/terrain_config_ui.tscn`

```
terrain_config_ui (Control)
├── header (Panel)
│   ├── title_label (Label)
│   ├── subtitle_label (Label)
│   ├── difficulty_option (OptionButton)
│   ├── back_button (Button)
│   └── start_button (Button)
├── content_hsplit (HSplitContainer)
│   ├── sidebar (Panel) - 左侧地形列表
│   │   ├── palette_scroll (ScrollContainer)
│   │   │   └── palette_vbox (VBoxContainer)
│   │   └── hint_label (Label)
│   └── main_area (Panel) - 右侧网格区域
│       ├── info_bar (HBoxContainer) - 顶部信息
│       ├── grid_container (GridContainer) - 4×7 网格
│       └── grid_labels (Control) - 坐标标签
└── footer (Panel)
    ├── reset_button (Button)
    └── status_bar (HBoxContainer)
```

**验收标准**: 场景结构完整，布局正确

---

### 步骤 5：实现 UI 控制器脚本
**文件**: `Scripts/ui/terrain_config/terrain_config_ui.gd`

```gdscript
extends Control
class_name TerrainConfigUI

## 地形配置 UI - 主控制器
##
## 功能：管理地形配置界面，处理拖拽和网格交互

signal tile_selected(terrain_type: StringName)
signal configuration_changed(edited_count: int)

@onready var _palette_vbox: VBoxContainer = $%PaletteVBox
@onready var _grid_container: GridContainer = $%GridContainer

## 初始化
func _ready() -> void:
    _setup_theme()
    _populate_palette()
    _create_grid_slots()

## 设置主题
func _setup_theme() -> void:
    var theme = load("res://Resources/ui/cyberpunk_theme.tres")
    set_theme(theme)

## 填充地形列表
func _populate_palette() -> void:
    var data = load("res://Resources/data/terrain_config_data.tres")
    for terrain in data.terrain_list:
        var item = terrain_palette_item_scene.instantiate()
        item.setup(terrain)
        _palette_vbox.add_child(item)

## 创建网格槽位
func _create_grid_slots() -> void:
    for i in range(28):  # 4×7
        var slot = grid_slot_scene.instantiate()
        slot.index = i
        slot.tile_placed.connect(_on_tile_placed)
        _grid_container.add_child(slot)
```

**验收标准**: 脚本无语法错误，符合编码规范

---

### 步骤 6：实现网格槽位组件
**文件**: `Scripts/ui/terrain_config/terrain_grid_slot.gd`

```gdscript
extends Control
class_name TerrainGridSlot

## 地形网格槽位 - 单个格子组件

signal tile_placed(index: int, terrain_type: StringName)

@export var index: int = 0
@export var current_terrain: StringName = &""

var _base_style: StyleBoxFlat
var _hover_style: StyleBoxFlat
var _occupied_style: StyleBoxFlat

func _ready() -> void:
    _create_styles()
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

## 创建样式
func _create_styles() -> void:
    _base_style = _create_base_style()
    _hover_style = _create_hover_style()
    _occupied_style = _create_occupied_style()
    add_theme_stylebox_override("panel", _base_style)

## 设置地形
func set_terrain(terrain_type: StringName) -> void:
    current_terrain = terrain_type
    add_theme_stylebox_override("panel", _occupied_style)
    # 添加图标
    _update_icon()

## Hover 动画
func _on_mouse_entered() -> void:
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "position:y", position.y - 2, 0.2)
```

**验收标准**: 悬停和放置效果正常

---

### 步骤 7：实现地形列表项组件
**文件**: `Scripts/ui/terrain_config/terrain_palette_item.gd`

```gdscript
extends Button
class_name TerrainPaletteItem

## 地形列表项 - 可拖拽的地形按钮

signal drag_started(terrain_type: StringName)

@export var terrain_data: TerrainEntry

func _ready() -> void:
    _setup_visuals()

func _get_drag_data(at_position: Vector2) -> Variant:
    # 创建拖拽预览
    var preview = duplicate()
    preview.modulate = Color(1, 1, 1, 0.8)
    set_drag_preview(preview)
    drag_started.emit(terrain_data.name)
    return terrain_data
```

**验收标准**: 拖拽功能正常

---

### 步骤 8：使用 GodotMCP 测试
**测试命令**:

```bash
# 启动 Godot 编辑器
mcp__godot-mcp__launch_editor(projectPath)

# 运行项目
mcp__godot-mcp__run_project(projectPath, scene="res://Scenes/ui/terrain_config/terrain_config_ui.tscn")

# 检查输出
mcp__godot-mcp__get_debug_output()
```

**验收标准**:
- 场景加载无错误
- UI 布局正确显示
- 动效流畅运行
- 拖拽功能正常

---

## 验证检查清单

- [ ] 所有 15 个图标已导入
- [ ] 主题资源可正常加载
- [ ] 地形数据资源可编辑
- [ ] 主场景结构正确
- [ ] 控制器脚本无错误
- [ ] 网格槽位悬停效果正常
- [ ] 拖拽功能正常工作
- [ ] GodotMCP 测试通过

---

## 关键文件清单

| 文件路径 | 类型 | 说明 |
|----------|------|------|
| `Assets/Icons/UI/*.svg` | 资源 | 15个图标 |
| `Resources/ui/cyberpunk_theme.tres` | 新建 | 主题资源 |
| `Resources/data/terrain_config_data.tres` | 新建 | 地形数据 |
| `Scenes/ui/terrain_config/terrain_config_ui.tscn` | 新建 | 主场景 |
| `Scripts/ui/terrain_config/terrain_config_ui.gd` | 新建 | 主控制器 |
| `Scripts/ui/terrain_config/terrain_grid_slot.gd` | 新建 | 网格槽位 |
| `Scripts/ui/terrain_config/terrain_palette_item.gd` | 新建 | 列表项 |

---

## 预期时间

| 步骤 | 预计操作 |
|------|----------|
| 导入图标 | 1 个文件操作 |
| 创建主题 | 1 个资源文件 |
| 创建地形数据 | 1 个资源文件 |
| 创建场景 | 1 个场景 + 7 个子节点 |
| 实现控制器 | 1 个脚本 |
| 实现槽位 | 1 个脚本 |
| 实现列表项 | 1 个脚本 |
| 测试 | GodotMCP 调用 |
