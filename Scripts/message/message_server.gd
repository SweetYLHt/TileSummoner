## 消息服务器
##
## 全局消息分发中心，作为 AutoLoad 单例使用
## 负责消息的发送、路由、过滤和统计
extends Node

## ========== 信号定义 ==========

## 消息已发送信号
signal message_sent(message)

## 消息被拦截信号
signal message_intercepted(message)

## 批量处理开始信号
signal batch_started(batch_id: int, message_count: int)

## 批量处理结束信号
signal batch_finished(batch_id: int)


## ========== 私有变量 ==========

## 消息过滤器
var _filter = null

## 消息历史记录
var _message_history: Array[Dictionary] = []

## 最大历史记录数量
const MAX_HISTORY_SIZE: int = 1000

## 批量处理缓冲区
var _batch_buffers: Dictionary = {}

## 批量处理 ID 计数器
var _next_batch_id: int = 0

## 当前激活的延迟发送定时器
var _delayed_timers: Array[Node] = []

## 统计信息
var _stats: Dictionary = {
	"total_sent": 0,
	"total_processed": 0,
	"total_intercepted": 0,
	"total_filtered": 0,
	"by_type": {}
}

## 调试模式开关
var debug_mode: bool = false

## 是否启用日志输出
var logging_enabled: bool = false


## ========== 公共方法 ==========

## 发送消息
## @param message: 要发送的消息实例
## @return 发送成功返回 true，失败返回 false
func send_message(message) -> bool:
	if not message:
		push_error("[MessageServer] Cannot send null message")
		return false

	# 应用过滤器
	if _filter and not _filter.should_pass(message):
		_stats.total_filtered += 1
		if logging_enabled:
			print("[MessageServer] Message filtered: %s" % message.get_message_type())
		return false

	# 更新统计
	_stats.total_sent += 1
	_update_type_stats(message.get_message_type())

	# 记录历史
	_add_to_history(message)

	# 检查拦截
	if message.is_intercepted():
		_stats.total_intercepted += 1
		message_intercepted.emit(message)
		if logging_enabled:
			print("[MessageServer] Message intercepted: %s, reason: %s" %
				[message.get_message_type(), message.intercept_reason])
		return true

	# 发送信号
	message_sent.emit(message)

	if debug_mode or logging_enabled:
		print("[MessageServer] Sent: %s" % message.get_debug_string())

	return true


## 延迟发送消息
## @param message: 要发送的消息实例
## @param delay_seconds: 延迟秒数
## @return 定时器节点，可用于取消延迟发送
func send_delayed(message, delay_seconds: float) -> Node:
	if not message:
		push_error("[MessageServer] Cannot send null delayed message")
		return null

	var timer := Timer.new()
	timer.wait_time = delay_seconds
	timer.one_shot = true
	timer.autostart = false

	# 创建回调闭包
	var callback := func():
		send_message(message)
		_delayed_timers.erase(timer)
		timer.queue_free()

	timer.timeout.connect(callback)
	add_child(timer)
	timer.start()

	_delayed_timers.append(timer)

	if logging_enabled:
		print("[MessageServer] Scheduled delayed message: %s, delay: %.2fs" %
			[message.get_message_type(), delay_seconds])

	return timer


## 开始批量处理
## @return 批量处理 ID
func begin_batch() -> int:
	_next_batch_id += 1
	var batch_id := _next_batch_id
	_batch_buffers[batch_id] = []
	return batch_id


## 添加消息到批量缓冲区
## @param message: 要添加的消息
## @param batch_id: 批量处理 ID（可选，默认最新的）
func add_to_batch(message, batch_id: int = -1) -> void:
	if batch_id == -1:
		batch_id = _next_batch_id

	if not _batch_buffers.has(batch_id):
		push_error("[MessageServer] Invalid batch_id: %d" % batch_id)
		return

	_batch_buffers[batch_id].append(message)


## 结束批量处理并发送所有消息
## @param batch_id: 批量处理 ID
## @return 实际发送的消息数量
func end_batch(batch_id: int) -> int:
	if not _batch_buffers.has(batch_id):
		push_error("[MessageServer] Invalid batch_id: %d" % batch_id)
		return 0

	var messages: Array = _batch_buffers[batch_id]
	_batch_buffers.erase(batch_id)

	if debug_mode or logging_enabled:
		print("[MessageServer] Batch %d started with %d messages" % [batch_id, messages.size()])

	batch_started.emit(batch_id, messages.size())

	var sent_count := 0
	for message in messages:
		if send_message(message):
			sent_count += 1

	batch_finished.emit(batch_id)

	if debug_mode or logging_enabled:
		print("[MessageServer] Batch %d finished, sent %d messages" % [batch_id, sent_count])

	# 更新处理统计
	_stats.total_processed += sent_count

	return sent_count


## 设置消息过滤器
## @param filter: 过滤器实例，传入 null 清除过滤器
func set_filter(filter) -> void:
	_filter = filter

	if logging_enabled:
		print("[MessageServer] Filter %s" % ("set" if filter else "cleared"))


## 清除消息过滤器
func clear_filter() -> void:
	_filter = null


## 获取统计信息
## @return 包含统计数据的字典
func get_statistics() -> Dictionary:
	return _stats.duplicate(true)


## 重置统计信息
func reset_statistics() -> void:
	_stats = {
		"total_sent": 0,
		"total_processed": 0,
		"total_intercepted": 0,
		"total_filtered": 0,
		"by_type": {}
	}


## 获取消息历史
## @param limit: 返回的最大条数（0 表示全部）
## @return 消息历史记录数组
func get_history(limit: int = 0) -> Array[Dictionary]:
	if limit <= 0:
		return _message_history.duplicate(true)

	var start := int(maxf(0, _message_history.size() - limit))
	return _message_history.slice(start)


## 清空消息历史
func clear_history() -> void:
	_message_history.clear()


## 启用调试模式
## @param enabled: 是否启用
func set_debug_mode(enabled: bool) -> void:
	debug_mode = enabled


## 启用日志输出
## @param enabled: 是否启用
func set_logging_enabled(enabled: bool) -> void:
	logging_enabled = enabled


## ========== 私有方法 ==========

## 添加消息到历史记录
func _add_to_history(message) -> void:
	var history_entry: Dictionary = message.get_debug_info()
	history_entry["processed_at"] = Time.get_unix_time_from_system()

	_message_history.append(history_entry)

	# 限制历史记录大小
	if _message_history.size() > MAX_HISTORY_SIZE:
		_message_history.pop_front()


## 更新类型统计
func _update_type_stats(type_name: StringName) -> void:
	if not _stats.by_type.has(type_name):
		_stats.by_type[type_name] = 0
	_stats.by_type[type_name] += 1


## ========== 生命周期 ==========

## 节点进入树时调用
func _ready() -> void:
	name = "MessageServer"
	if logging_enabled:
		print("[MessageServer] Initialized")


## 节点退出树时清理资源
func _exit_tree() -> void:
	# 清理所有延迟定时器
	for timer in _delayed_timers:
		if is_instance_valid(timer):
			timer.queue_free()

	_delayed_timers.clear()

	# 清理批量缓冲区
	_batch_buffers.clear()
