#!/bin/bash
# GDScript Lint Hook 安装脚本
# 用法: ./install.sh

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 GDScript Lint Hook 安装程序"
echo "================================"

# 检查依赖
echo ""
echo "📋 检查依赖..."

# 检查 gdlint
if ! command -v gdlint &> /dev/null; then
    echo "❌ 未找到 gdlint"
    echo "   请先安装 godot-gdscript-toolkit:"
    echo "   pip install gdtoolkit"
    exit 1
fi
echo "✅ gdlint 已安装"

# 检查 jq (可选)
if command -v jq &> /dev/null; then
    echo "✅ jq 已安装"
else
    echo "⚠️  jq 未安装 (将使用 python3 作为替代)"
fi

# 创建目录
echo ""
echo "📁 创建目录..."
mkdir -p "$HOOKS_DIR"
echo "✅ $HOOKS_DIR"

# 复制脚本
echo ""
echo "📄 安装 hook 脚本..."
cp "$SCRIPT_DIR/check-gdscript.sh" "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR/check-gdscript.sh"
echo "✅ $HOOKS_DIR/check-gdscript.sh"

# 更新 settings.json
echo ""
echo "⚙️  配置 settings.json..."

if [ ! -f "$SETTINGS_FILE" ]; then
    # 创建新的 settings.json
    cat > "$SETTINGS_FILE" << 'EOF'
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
EOF
    echo "✅ 创建了新的 settings.json"
else
    # 检查是否已有 hooks 配置
    if grep -q "check-gdscript.sh" "$SETTINGS_FILE" 2>/dev/null; then
        echo "⚠️  settings.json 中已存在 check-gdscript.sh 配置"
    else
        echo "⚠️  settings.json 已存在，请手动添加以下配置:"
        echo ""
        cat << 'EOF'
在 settings.json 中添加或合并以下内容:

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
EOF
    fi
fi

echo ""
echo "================================"
echo "✅ 安装完成!"
echo ""
echo "📝 使用说明:"
echo "   1. 重启 Claude Code 使配置生效"
echo "   2. 当创建或编辑 .gd 文件时，会自动运行 gdlint 检查"
echo "   3. 如果代码有问题，会显示警告消息"
echo ""
