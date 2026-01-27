---
name: auto-validate-gdscript
enabled: true
event: file
action: warn
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.gd$
---

## GDScript 自动验证规则

检测到您刚刚创建或编辑了 `.gd` 文件。根据项目规则，需要使用 Godot LSP 进行代码验证。

### 验证方式

**MCP 工具验证：**
- lint: `mcp__godot-ultimate__godot_lint_file`
- 格式化: `mcp__godot-ultimate__godot_format_file`
- 验证项目: `mcp__godot-ultimate__godot_validate_project`

**Godot 编辑器验证：**
在 Godot 编辑器中打开项目，LSP 会自动进行语法检查。

### 重要提醒

- 只有验证通过的代码才能提交到版本控制
- 发现的错误应立即修复
- 验证失败会显示具体的错误位置和修复建议
