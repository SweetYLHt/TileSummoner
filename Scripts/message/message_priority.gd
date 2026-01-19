## 消息优先级枚举
##
## 用于定义消息处理和分发的优先级顺序
extends RefCounted
class_name MessagePriority

## 低优先级 - UI更新、音效播放、视觉特效
const LOW: int = 0

## 普通优先级 - 常规游戏事件
const NORMAL: int = 10

## 高优先级 - 影响游戏状态的重要事件
const HIGH: int = 20

## 关键优先级 - 断路判负、游戏结束等决定性事件
const CRITICAL: int = 30
