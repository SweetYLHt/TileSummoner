## 消息基类
##
## 所有游戏消息的基类，提供消息的基本功能和属性
extends RefCounted
class_name Message

## 全局消息 ID 计数器
static var _next_message_id: int = 0

## 生成新的唯一消息 ID
static func _generate_message_id() -> int:
	_next_message_id += 1
	return _next_message_id

## 消息唯一标识符
var message_id: int = _generate_message_id()

## 消息时间戳（创建时间）
var timestamp: float = Time.get_unix_time_from_system()

## 消息发送者（通常是 Node 引用）
var sender: Object = null

## 消息优先级（默认普通）
var priority: int = MessagePriority.NORMAL

## 消息是否已被拦截
var _is_intercepted: bool = false

## 消息是否已被阻止处理
var _is_blocked: bool = false

## 拦截原因（调试用）
var intercept_reason: String = ""

## 阻止原因（调试用）
var block_reason: String = ""


## 获取消息类型名称
## 子类应重写此方法返回具体的类型标识
func get_message_type() -> StringName:
	return &"Message"


## 拦截此消息
## @param reason: 拦截原因描述
func intercept(reason: String = "") -> void:
	_is_intercepted = true
	intercept_reason = reason


## 检查消息是否已被拦截
func is_intercepted() -> bool:
	return _is_intercepted


## 阻止此消息被处理
## @param reason: 阻止原因描述
func block(reason: String = "") -> void:
	_is_blocked = true
	block_reason = reason


## 检查消息是否已被阻止
func is_blocked() -> bool:
	return _is_blocked


## 重置拦截和阻止状态
## 用于消息复用场景
func reset_status() -> void:
	_is_intercepted = false
	_is_blocked = false
	intercept_reason = ""
	block_reason = ""


## 获取调试信息
## @return 包含消息详细信息的字典
func get_debug_info() -> Dictionary:
	return {
		"message_id": message_id,
		"type": get_message_type(),
		"timestamp": timestamp,
		"sender": sender.get_class() if sender else "null",
		"priority": priority,
		"is_intercepted": _is_intercepted,
		"is_blocked": _is_blocked,
		"intercept_reason": intercept_reason,
		"block_reason": block_reason
	}


## 获取格式化的调试字符串
func get_debug_string() -> String:
	var info := get_debug_info()
	return "[Message ID:%d Type:%s Priority:%d Sender:%s]" % [
		info.message_id, info.type, info.priority, info.sender
	]
