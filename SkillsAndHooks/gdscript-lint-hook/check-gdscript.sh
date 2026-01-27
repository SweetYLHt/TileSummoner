#!/bin/bash
# GDScript Lint Hook for Claude Code
# 当 .gd 文件被创建或修改时自动运行 gdlint 检查
# https://github.com/Scony/godot-gdscript-toolkit

# 从 stdin 读取 JSON 输入
read -r json_input

# 使用 jq 解析文件路径
if command -v jq &> /dev/null; then
    FILE_PATH=$(echo "$json_input" | jq -r '.tool_input.file_path // empty')
else
    FILE_PATH=$(echo "$json_input" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)
fi

# 检查是否获取到文件路径
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# 检查是否是 .gd 文件
if [[ ! "$FILE_PATH" =~ \.gd$ ]]; then
    exit 0
fi

# 检查文件是否存在
if [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# 运行 gdlint 检查
LINT_OUTPUT=$(gdlint "$FILE_PATH" 2>&1)
LINT_EXIT_CODE=$?

# 转义 JSON 特殊字符
ESCAPED_OUTPUT=$(echo "$LINT_OUTPUT" | jq -Rs '.' 2>/dev/null || echo "\"$LINT_OUTPUT\"")

if [ $LINT_EXIT_CODE -eq 0 ]; then
    # 通过时静默
    exit 0
else
    # 有问题时，显示阻止消息
    cat << EOF
{
  "decision": "block",
  "reason": "GDScript 代码检查发现问题",
  "description": $ESCAPED_OUTPUT
}
EOF
fi

exit 0
