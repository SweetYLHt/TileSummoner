## 消息过滤器
##
## 用于过滤消息，控制哪些消息应该被处理
extends RefCounted

## 优先级常量
const PRIORITY_LOW: int = 0
const PRIORITY_NORMAL: int = 10
const PRIORITY_HIGH: int = 20
const PRIORITY_CRITICAL: int = 30

## 类型白名单（空列表表示不限制）
var _type_whitelist: Array[StringName] = []

## 类型黑名单
var _type_blacklist: Array[StringName] = []

## 发送者白名单（空列表表示不限制）
var _sender_whitelist: Array[Object] = []

## 最低优先级阈值（低于此优先级的消息将被过滤）
var _min_priority: int = PRIORITY_LOW

## 自定义过滤函数列表
var _custom_filters: Array[Callable] = []

## 是否启用白名单模式
var _whitelist_mode: bool = false


## 创建默认过滤器
static func create():
	var script := load("res://scripts/message/message_filter.gd")
	return script.new()


## 设置类型白名单
## @param types: 允许的消息类型列表
## @return self，支持链式调用
func with_type_whitelist(types: Array[StringName]):
	_type_whitelist = types
	_whitelist_mode = true
	return self


## 设置类型黑名单
## @param types: 禁止的消息类型列表
## @return self，支持链式调用
func with_type_blacklist(types: Array[StringName]):
	_type_blacklist = types
	return self


## 设置发送者白名单
## @param senders: 允许的发送者列表
## @return self，支持链式调用
func with_sender_whitelist(senders: Array[Object]):
	_sender_whitelist = senders
	_whitelist_mode = true
	return self


## 设置最低优先级
## @param priority: 最低允许的优先级
## @return self，支持链式调用
func with_min_priority(priority: int):
	_min_priority = priority
	return self


## 添加自定义过滤函数
## @param filter_func: 接收 Message 返回 bool 的函数
## @return self，支持链式调用
func with_custom_filter(filter_func: Callable):
	_custom_filters.append(filter_func)
	return self


## 清除所有过滤规则
func clear() -> void:
	_type_whitelist.clear()
	_type_blacklist.clear()
	_sender_whitelist.clear()
	_custom_filters.clear()
	_min_priority = PRIORITY_LOW
	_whitelist_mode = false


## 检查消息是否应该被通过
## @param message: 要检查的消息
## @return true 表示消息通过，false 表示被过滤
func should_pass(message) -> bool:
	if not message:
		return false

	# 优先级检查
	if message.priority < _min_priority:
		return false

	# 白名单模式
	if _whitelist_mode:
		# 类型白名单检查
		if not _type_whitelist.is_empty():
			if message.get_message_type() not in _type_whitelist:
				return false

		# 发送者白名单检查
		if not _sender_whitelist.is_empty():
			if message.sender not in _sender_whitelist:
				return false

	# 黑名单检查
	if not _type_blacklist.is_empty():
		if message.get_message_type() in _type_blacklist:
			return false

	# 自定义过滤器检查
	for filter_func in _custom_filters:
		if not filter_func.call(message):
			return false

	return true


## 获取过滤器调试信息
func get_debug_info() -> Dictionary:
	return {
		"whitelist_mode": _whitelist_mode,
		"type_whitelist": _type_whitelist,
		"type_blacklist": _type_blacklist,
		"sender_whitelist_size": _sender_whitelist.size(),
		"min_priority": _min_priority,
		"custom_filters_count": _custom_filters.size()
	}
