# 技术栈

## 核心技术
- **游戏引擎**: Godot 4.5.1
- **编程语言**: GDScript
- **渲染**: Forward Plus渲染管线
- **目标平台**: macOS, Windows, Linux

## Godot 特性使用
- **节点系统**: Node2D, Sprite2D, Area2D
- **资源系统**: Resource, .tres 数据驱动
- **AutoLoad 单例**: MessageServer, TileDatabase
- **信号系统**: GUI 输入、自定义信号
- **Tween**: 动画系统
- **场景实例化**: 地块动态生成

## 设计模式
- **单例模式**: MessageServer, TileDatabase (AutoLoad)
- **工厂模式**: 地块创建 (TILE_SCENE.instantiate())
- **观察者模式**: MessageServer 消息广播
- **数据驱动**: TileData, TileConfig 资源文件

## 关键系统
1. **消息系统**: 19种消息类型，解耦模块间依赖
2. **地形系统**: 9种地形，数据驱动配置
3. **网格系统**: 7×9 网格，坐标系统
4. **库存系统**: Dictionary 存储地块数量

## 文件命名规范
- 场景文件: `*.tscn` (如 `tile.tscn`)
- 脚本文件: `*.gd` (如 `tile.gd`)
- 资源文件: `*.tres` (如 `grassland.tres`)
- 文档文件: `*.md` (如 `实现总结.md`)

## 目录结构规范
- `Scripts/模块名/` - 该模块的脚本
- `Scenes/模块名/` - 该模块的场景
- `Resources/模块名/` - 该模块的资源
