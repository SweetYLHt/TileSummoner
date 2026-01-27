---
name: block-emoji
enabled: true
event: file
action: block
conditions:
  - field: new_text
    operator: contains
    pattern: "🎮"
---

## 禁止使用 Emoji

检测到文件中包含 emoji 表情符号。操作已阻止。

### 项目规则

根据 `CLAUDE.md` 中的编码规范：
- **无表情符号**：代码、注释、文档中不使用 emoji

### 原因

1. Emoji 在不同环境下显示效果不一致
2. 可能导致编码问题
3. 影响代码专业性
4. 部分编辑器/终端无法正确显示

### 解决方案

请移除所有 emoji 表情符号，使用文字描述替代：

**错误示例:**
```gdscript
# TODO: 修复这个 bug
print("成功!")
```

**正确示例:**
```gdscript
# TODO: 修复这个 bug
print("成功!")
```

请移除所有 emoji 后再保存文件。
