## UI 主题常量
##
## 统一定义 UI 组件使用的颜色、尺寸等常量
## 合并自 MenuButtonStyler 和 SettingsPopupStyle
extends RefCounted
class_name UIThemeConstants


## ============================================================================
## 主题色
## ============================================================================

## 金色主题色
const GOLD := Color(0.87, 0.7, 0.16, 1.0)          # #dfb22a
const GOLD_BRIGHT := Color(0.94, 0.78, 0.23, 1.0)  # #f0c83a
const GOLD_DARK := Color(0.7, 0.56, 0.13, 1.0)     # 深金色

## 红色 (危险/警告)
const RED_HOVER := Color(0.8, 0.2, 0.2, 1.0)       # #cc3333
const RED_TEXT := Color(1.0, 0.267, 0.267, 1.0)    # #ff4444


## ============================================================================
## 背景色
## ============================================================================

## 深色背景
const BG_DARK := Color(0.04, 0.047, 0.059, 1.0)           # #0a0c0f
const BG_HOVER := Color(0.059, 0.067, 0.078, 1.0)         # #0f1114
const BG_HOVER_LIGHT := Color(0.08, 0.09, 0.11, 1.0)      # 浅一点的 hover
const BG_HOVER_RED := Color(0.102, 0.039, 0.039, 1.0)     # #1a0a0a 红色背景

## 玻璃效果背景
const GLASS_BG := Color(0.051, 0.059, 0.078, 0.92)        # rgba(13, 15, 20, 0.92)
const FOOTER_BG := Color(0.0, 0.0, 0.0, 0.4)              # 底栏半透明


## ============================================================================
## 边框色
## ============================================================================

const BORDER_SUBTLE := Color(0.176, 0.184, 0.2, 1.0)      # #2d2f33
const BORDER_GRAY := Color(0.267, 0.251, 0.235, 1.0)      # #44403c
const BORDER_GRAY_LIGHT := Color(0.47, 0.44, 0.42, 1.0)   # #78716c
const BORDER_LIGHT := Color(0.3, 0.32, 0.35, 1.0)         # 较亮边框


## ============================================================================
## 文字颜色
## ============================================================================

const TEXT_WHITE := Color(1.0, 1.0, 1.0, 1.0)
const TEXT_GRAY_WHITE := Color(0.84, 0.83, 0.82, 1.0)     # #d6d3d1
const TEXT_GRAY := Color(0.66, 0.63, 0.62, 1.0)           # #a8a29e
const TEXT_GRAY_LIGHT := Color(0.7, 0.7, 0.7, 1.0)        # 设置面板灰色
const TEXT_DARK := Color(0.1, 0.1, 0.1, 1.0)              # 深色文字 (金色按钮用)


## ============================================================================
## 滑块颜色
## ============================================================================

const SLIDER_TRACK_BG := Color(0.16, 0.18, 0.2, 1.0)
const SLIDER_FILL := Color(0.87, 0.7, 0.16, 0.8)
const SLIDER_GRABBER_GLOW := Color(0.87, 0.7, 0.16, 0.8)


## ============================================================================
## 开关颜色
## ============================================================================

const TOGGLE_ON_BG := Color(0.87, 0.7, 0.16, 1.0)
const TOGGLE_OFF_BG := Color(0.2, 0.22, 0.25, 1.0)


## ============================================================================
## 分隔线颜色
## ============================================================================

const SEPARATOR_COLOR := Color(0.25, 0.27, 0.3, 0.5)


## ============================================================================
## 尺寸常量
## ============================================================================

## 圆角
const CORNER_RADIUS := 12
const CORNER_RADIUS_SMALL := 6
const CORNER_RADIUS_TINY := 4

## 内边距
const CONTENT_MARGIN := 24
const CONTENT_MARGIN_SMALL := 12
const CONTENT_MARGIN_TINY := 8

## 边框宽度
const BORDER_WIDTH := 1
const BORDER_WIDTH_LEFT_ACCENT := 4

## 滑块
const GRABBER_WIDTH := 12
const GRABBER_HEIGHT := 24
const GRABBER_GLOW_PADDING := 4
const SLIDER_TRACK_EXPAND := 3

## 字体
const FONT_SIZE_DEFAULT := 18
const FONT_SIZE_SMALL := 14
const FONT_SIZE_TITLE := 16
