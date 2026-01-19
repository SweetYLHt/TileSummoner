#!/usr/bin/env bash

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           地块系统代码验证工具                                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (文件不存在)"
        return 1
    fi
}

# 计数器
total_files=0
passed_files=0

echo "📂 检查脚本文件..."
echo "────────────────────────────────────────────────────────────────"

scripts=(
    "Scripts/tile/tile_data.gd"
    "Scripts/tile/tile_config.gd"
    "Scripts/tile/tile_database.gd"
    "Scripts/tile/tile.gd"
    "Scripts/tile/grid_manager.gd"
    "Scripts/tile/battle_map_generator.gd"
    "Scripts/inventory/tile_inventory.gd"
    "Scripts/test/test_tile_system.gd"
)

for script in "${scripts[@]}"; do
    total_files=$((total_files + 1))
    if check_file "$script"; then
        passed_files=$((passed_files + 1))
    fi
done

echo ""
echo "📦 检查资源文件..."
echo "────────────────────────────────────────────────────────────────"

resources=(
    "Resources/Tiles/grassland.tres"
    "Resources/Tiles/water.tres"
    "Resources/Tiles/sand.tres"
    "Resources/Tiles/rock.tres"
    "Resources/Tiles/forest.tres"
    "Resources/Tiles/farmland.tres"
    "Resources/Tiles/lava.tres"
    "Resources/Tiles/swamp.tres"
    "Resources/Tiles/ice.tres"
)

for resource in "${resources[@]}"; do
    total_files=$((total_files + 1))
    if check_file "$resource"; then
        passed_files=$((passed_files + 1))
    fi
done

echo ""
echo "📋 检查配置文件..."
echo "────────────────────────────────────────────────────────────────"

configs=(
    "Resources/Tiles/Configs/player_default.tres"
    "Resources/Tiles/Configs/enemy_easy.tres"
    "Resources/Tiles/Configs/enemy_medium.tres"
    "Resources/Tiles/Configs/enemy_hard.tres"
)

for config in "${configs[@]}"; do
    total_files=$((total_files + 1))
    if check_file "$config"; then
        passed_files=$((passed_files + 1))
    fi
done

echo ""
echo "🎬 检查场景文件..."
echo "────────────────────────────────────────────────────────────────"

scenes=(
    "Scenes/tile/tile.tscn"
    "Scenes/battle_map.tscn"
    "Scenes/test_tile_system.tscn"
)

for scene in "${scenes[@]}"; do
    total_files=$((total_files + 1))
    if check_file "$scene"; then
        passed_files=$((passed_files + 1))
    fi
done

echo ""
echo "📄 检查文档文件..."
echo "────────────────────────────────────────────────────────────────"

docs=(
    "Docs/地块系统实现总结.md"
    "Docs/地块系统快速开始.md"
)

for doc in "${docs[@]}"; do
    total_files=$((total_files + 1))
    if check_file "$doc"; then
        passed_files=$((passed_files + 1))
    fi
done

echo ""
echo "🔍 检查 AutoLoad 配置..."
echo "────────────────────────────────────────────────────────────────"

if grep -q "TileDatabase" project.godot; then
    echo -e "${GREEN}✓${NC} TileDatabase 已注册为 AutoLoad"
    passed_files=$((passed_files + 1))
else
    echo -e "${RED}✗${NC} TileDatabase 未在 AutoLoad 中注册"
fi
total_files=$((total_files + 1))

if grep -q "MessageServer" project.godot; then
    echo -e "${GREEN}✓${NC} MessageServer 已注册为 AutoLoad"
    passed_files=$((passed_files + 1))
else
    echo -e "${YELLOW}⚠${NC} MessageServer 未在 AutoLoad 中注册"
fi
total_files=$((total_files + 1))

echo ""
echo "🎯 检查主场景配置..."
echo "────────────────────────────────────────────────────────────────"

if grep -q "test_tile_system.tscn" project.godot; then
    echo -e "${GREEN}✓${NC} 主场景已设置为 test_tile_system.tscn"
    passed_files=$((passed_files + 1))
else
    echo -e "${YELLOW}⚠${NC} 主场景未设置为测试场景"
fi
total_files=$((total_files + 1))

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "📊 验证结果汇总"
echo "════════════════════════════════════════════════════════════════"

percentage=$((passed_files * 100 / total_files))

echo -e "通过率: ${passed_files}/${total_files} (${percentage}%)"

if [ $percentage -eq 100 ]; then
    echo -e "${GREEN}✓ 所有检查通过！系统可以运行。${NC}"
    echo ""
    echo "🚀 下一步："
    echo "   1. 打开 Godot 编辑器"
    echo "   2. 按 F5 运行测试场景"
    echo "   3. 观察控制台输出和地图生成"
    exit 0
elif [ $percentage -ge 80 ]; then
    echo -e "${YELLOW}⚠ 大部分检查通过，但可能有问题。${NC}"
    exit 1
else
    echo -e "${RED}✗ 检查失败率过高，请检查文件完整性。${NC}"
    exit 1
fi
