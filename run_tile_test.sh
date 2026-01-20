#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           地块系统自动化测试脚本                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_PATH="/Users/sweety/TileSummoner"

echo "📍 项目路径: $PROJECT_PATH"
echo "🎮 Godot 路径: $GODOT_PATH"
echo ""

# 检查文件
echo "🔍 步骤 1: 检查项目文件..."
echo "────────────────────────────────────────────────────────────────"

required_files=(
    "Scripts/tile/tile_block_data.gd"
    "Scripts/tile/tile_database.gd"
    "Scripts/tile/tile.gd"
    "Scripts/tile/grid_manager.gd"
    "Scripts/tile/battle_map_generator.gd"
    "Resources/Tiles/grassland.tres"
    "Scenes/tile/tile.tscn"
    "Scenes/test_tile_system.tscn"
    "project.godot"
)

all_exist=true
for file in "${required_files[@]}"; do
    if [ -f "$PROJECT_PATH/$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (缺失)"
        all_exist=false
    fi
done

echo ""

if [ "$all_exist" = false ]; then
    echo "❌ 文件检查失败，请先完成实现"
    exit 1
fi

echo "✅ 文件检查通过"
echo ""

# 检查 AutoLoad 配置
echo "🔍 步骤 2: 检查 AutoLoad 配置..."
echo "────────────────────────────────────────────────────────────────"

if grep -qi "tileDatabase" "$PROJECT_PATH/project.godot"; then
    echo "  ✓ TileDatabase 已配置"
else
    echo "  ✗ TileDatabase 未配置"
    exit 1
fi

echo ""

# 创建临时测试输出文件
OUTPUT_FILE=$(mktemp)
echo "🧪 步骤 3: 运行 Godot 测试..."
echo "────────────────────────────────────────────────────────────────"
echo "输出文件: $OUTPUT_FILE"
echo ""

# 运行 Godot（headless 模式，10秒超时）
echo "启动 Godot（headless 模式）..."

(
    timeout 10 "$GODOT_PATH" --path "$PROJECT_PATH" --headless --verbose 2>&1 || true
) > "$OUTPUT_FILE" 2>&1 &

GODOT_PID=$!
echo "Godot PID: $GODOT_PID"

# 等待进程
sleep 8

# 检查输出
echo ""
echo "📊 测试输出分析："
echo "────────────────────────────────────────────────────────────────"

if [ -s "$OUTPUT_FILE" ]; then
    # 统计输出
    total_lines=$(wc -l < "$OUTPUT_FILE")
    error_count=$(grep -c -i "error\|failed\|exception" "$OUTPUT_FILE" 2>/dev/null || echo 0)
    tile_count=$(grep -c "Tile" "$OUTPUT_FILE" 2>/dev/null || echo 0)

    echo "  总输出行数: $total_lines"
    echo "  错误数量: $error_count"
    echo "  Tile 提及次数: $tile_count"

    echo ""
    echo "📝 关键输出（最后20行）："
    tail -20 "$OUTPUT_FILE" | sed 's/^/  /'

    # 检查是否成功
    echo ""
    if [ "$error_count" -eq 0 ]; then
        echo "✅ 测试通过（无错误）"
    else
        echo "⚠️  发现 $error_count 个错误"
    fi
else
    echo "⚠️  无输出或 Godot 未启动"
fi

# 清理
kill $GODOT_PID 2>/dev/null
rm -f "$OUTPUT_FILE"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✅ 测试完成"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "💡 建议："
echo "   1. 在 Godot 编辑器中按 F5 查看可视化效果"
echo "   2. 检查控制台输出中的测试结果"
echo "   3. 验证地图生成动画（7×9网格）"
echo ""
