# GDScript Lint Hook for Claude Code

当 Claude Code 创建或编辑 `.gd` 文件时，自动运行 [gdlint](https://github.com/Scony/godot-gdscript-toolkit) 代码检查。

## 功能

- ✅ 自动检测 `.gd` 文件的创建和修改
- ✅ 运行 gdlint 代码风格检查
- ✅ 发现问题时显示警告消息
- ✅ 代码通过时静默不打扰

## 前置要求

1. **Claude Code** - Anthropic 官方 CLI 工具
2. **gdtoolkit** - GDScript 工具包

安装 gdtoolkit:
```bash
pip install gdtoolkit
```

## 安装方法

### 方法一：自动安装

```bash
cd gdscript-lint-hook
chmod +x install.sh
./install.sh
```

### 方法二：手动安装

#### 1. 复制 hook 脚本

```bash
mkdir -p ~/.claude/hooks
cp check-gdscript.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/check-gdscript.sh
```

#### 2. 配置 settings.json

编辑 `~/.claude/settings.json`，添加以下内容：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/check-gdscript.sh",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

如果文件已有其他配置，需要合并 `hooks` 部分。

#### 3. 重启 Claude Code

```bash
# 退出当前会话
/exit

# 重新启动
claude
```

## 使用效果

当代码有问题时：
```
PostToolUse:Write hook blocking error: GDScript 代码检查发现问题
```

代码通过时：静默，无输出

## 手动检查

```bash
gdlint your_script.gd
```

## 文件结构

```
~/.claude/
├── hooks/
│   └── check-gdscript.sh    # Hook 脚本
└── settings.json            # Claude Code 配置
```

## 卸载

```bash
rm ~/.claude/hooks/check-gdscript.sh
# 然后从 settings.json 中移除 hooks 配置
```

## 许可

MIT License
