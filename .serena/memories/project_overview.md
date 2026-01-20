# TileSummoner 项目概览

## 项目目的
TileSummoner（地块召唤师）是一款策略自走棋 + 卡牌构建 + 地形编辑游戏。

## 核心玩法
- **7×9 非对称地图**：我方4行 vs 敌方5行
- **9种地形类型**：草地、水域、沙地、岩石、森林、农田、熔岩、沼泽、冰原
- **地块消耗→单位召唤**：在地块上消耗地块召唤单位
- **连通性规则**：断路判负、虚空坠毁
- **多资源经济**：法力、地块、金币、卡牌、遗物

## 胜负条件
摧毁敌方主基地（需先摧毁防御塔）

## 项目结构
```
TileSummoner/
├── Assets/           # 美术资源（贴图、音频等）
├── Docs/            # 设计文档和开发记录
├── Resources/       # Godot 资源文件（.tres）
├── Scenes/          # Godot 场景文件（.tscn）
├── Scripts/         # 游戏逻辑脚本（.gd）
└── project.godot    # Godot 项目配置
```

## 开发环境
- **引擎**: Godot 4.5.1
- **语言**: GDScript
- **平台**: macOS (Darwin)
- **IDE**: Godot Editor

## 已实现模块
1. **消息系统** (Scripts/message/) - 19种消息类型，MessageServer 单例
2. **地块系统** (Scripts/tile/) - 完整的地形数据、网格管理、地图生成
3. **库存系统** (Scripts/inventory/) - 地块库存管理
4. **测试系统** (Scripts/test/) - 单元测试和验证

## 待实现模块
- 单位系统
- 卡牌系统
- 战斗逻辑
- 连通性算法
- UI编辑系统
- 经济系统
