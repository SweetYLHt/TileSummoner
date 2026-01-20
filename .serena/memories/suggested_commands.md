# 常用开发命令

## Godot 相关

### 运行项目
```bash
# 命令行运行（headless 模式）
/Applications/Godot.app/Contents/MacOS/Godot --path . --headless

# 打开编辑器
open -a Godot
```

### 编辑器快捷键
- `F5` - 运行当前项目
- `F6` - 运行当前场景
- `Cmd+S` - 保存当前场景
- `Cmd+Shift+S` - 保存所有场景

## Git 相关

### 基本操作
```bash
# 查看状态
git status
git status --short

# 添加文件
git add Scripts/tile/
git add Resources/Tiles/

# 提交
git commit -m "feat: 描述"

# 查看历史
git log --oneline -5
git log --graph --all

# 分支操作
git branch          # 查看分支
git checkout -b     # 创建并切换分支
git merge           # 合并分支
```

### 项目特定
```bash
# 查看项目修改
git diff project.godot

# 添加所有地块系统文件
git add Scripts/tile/ Scripts/inventory/ Scripts/test/
git add Resources/Tiles/
git add Scenes/tile/ Scenes/battle_map.tscn Scenes/test_tile_system.tscn
```

## 系统工具

### 文件操作
```bash
# 列出文件
ls -la
find Scripts -name "*.gd"

# 查找文件
find . -name "tile_database.gd"

# 统计代码行数
find Scripts -name "*.gd" | xargs wc -l
```

### 搜索
```bash
# 搜索文件内容
grep -r "TileData" Scripts/

# 搜索特定文件
grep "class_name" Scripts/tile/*.gd
```

## 测试和验证

### 运行验证脚本
```bash
# 完整验证
./verify_tile_system.sh

# 查看测试输出
open -a Godot
# 然后在编辑器中按 F5
```

### 手动测试清单
1. ✅ 检查所有文件是否存在
2. ✅ 验证 AutoLoad 配置
3. ✅ 运行测试场景
4. ✅ 检查控制台输出
5. ✅ 验证地图生成
6. ✅ 测试地块替换

## 代码质量

### 检查代码
```bash
# 查找语法错误（通过 Godot 编辑器）
# 1. 打开 Godot 编辑器
# 2. 查看"问题"面板
# 3. 修复所有错误和警告
```

### 代码格式化
- 使用 Godot 编辑器的自动格式化功能
- 快捷键: `Cmd+Alt+T`（格式化选中代码）
- 设置: 编辑器 → 文本编辑器 → 缩进

## 文档生成

### 查看文档
```bash
# 打开实现总结
open Docs/地块系统实现总结.md

# 打开快速开始
open Docs/地块系统快速开始.md

# 打开编码标准
open Docs/CODING_STANDARDS.md
```

## 清理和重置

### 清理临时文件
```bash
# 清理 Godot 导入文件
rm -rf .godot/imported/

# 重新导入资源
# 在 Godot 编辑器中: 项目 → 工具 → 重新导入资源
```

## 调试

### 启用调试输出
```gdscript
# 在代码中添加调试输出
print("Debug message: %s" % value)

# 查看变量
prints("变量值", variable)
```

### 性能分析
```bash
# 在 Godot 编辑器中
# 1. 运行项目
# 2. 查看"性能"面板
# 3. 分析帧率和draw_calls
```

## 常见问题排查

### 问题: AutoLoad 未加载
```bash
# 检查 project.godot
grep "TileDatabase" project.godot

# 应该看到:
# TileDatabase="*res://Scripts/tile/tile_database.gd"
```

### 问题: 资源未加载
```bash
# 检查资源文件是否存在
ls Resources/Tiles/*.tres

# 检查路径是否正确
grep "res://Resources" Scripts/tile/tile_database.gd
```
