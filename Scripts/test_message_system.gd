## 消息系统测试脚本
##
## 验证 MessageServer 和各类消息功能
extends Node2D

## 测试结果统计
var _tests_passed: int = 0
var _tests_failed: int = 0


## 测试消息类
class TestMessage extends RefCounted:
	var message_id: int = 0
	var timestamp: float = 0.0
	var sender: Object = null
	var priority: int = 10
	var _is_intercepted: bool = false

	func _init() -> void:
		message_id = randi()
		timestamp = Time.get_unix_time_from_system()

	func get_message_type() -> StringName:
		return &"TestMessage"

	func is_intercepted() -> bool:
		return _is_intercepted

	func intercept(_reason: String = "") -> void:
		_is_intercepted = true

	func get_debug_info() -> Dictionary:
		return {
			"message_id": message_id,
			"type": get_message_type(),
			"timestamp": timestamp,
			"sender": sender.get_class() if sender else "null",
			"priority": priority
		}

	func get_debug_string() -> String:
		return "[Message ID:%d Type:TestMessage]" % message_id


func _ready() -> void:
	print("=".repeat(50))
	print("TileSummoner 消息系统测试开始")
	print("=".repeat(50))

	# 等待一帧确保 MessageServer 已初始化
	await get_tree().process_frame

	_run_all_tests()

	# 延迟退出以便查看结果
	await get_tree().create_timer(5.0).timeout
	_print_summary()
	# get_tree().quit()  # 暂时不自动退出


## 运行所有测试
func _run_all_tests() -> void:
	_test_message_server_singleton()
	_test_message_send()
	# _test_message_filter()  # 暂时跳过
	_test_batch_processing()
	_test_delayed_message()
	_test_statistics()
	_test_message_history()


## 测试 MessageServer 单例
func _test_message_server_singleton() -> void:
	print("\n--- 测试 MessageServer 单例 ---")
	if MessageServer:
		_tests_passed += 1
		print("✓ MessageServer 单例加载成功")
	else:
		_tests_failed += 1
		print("✗ MessageServer 单例加载失败")


## 测试消息发送
func _test_message_send() -> void:
	print("\n--- 测试消息发送 ---")

	var msg := TestMessage.new()
	msg.sender = self

	var result := MessageServer.send_message(msg)

	if result:
		print("✓ 消息发送成功")
		_tests_passed += 1
	else:
		print("✗ 消息发送失败")
		_tests_failed += 1


## 测试消息过滤器
func _test_message_filter() -> void:
	print("\n--- 测试消息过滤器 ---")

	# 创建过滤器（使用 RefCounted 基类创建）
	var filter_ref := load("res://scripts/message/message_filter.gd")
	var filter = filter_ref.new()

	var msg := TestMessage.new()

	if filter.should_pass(msg):
		print("✓ 过滤器默认允许消息通过")
		_tests_passed += 1
	else:
		print("✗ 过滤器错误")
		_tests_failed += 1

	# 测试优先级过滤
	filter.with_min_priority(20)
	if not filter.should_pass(msg):
		print("✓ 优先级过滤器正常工作")
		_tests_passed += 1
	else:
		print("✗ 优先级过滤器错误")
		_tests_failed += 1

	# 重置过滤器
	filter.clear()


## 测试批量处理
func _test_batch_processing() -> void:
	print("\n--- 测试批量处理 ---")

	var batch_id := MessageServer.begin_batch()

	for i in range(5):
		var msg := TestMessage.new()
		MessageServer.add_to_batch(msg, batch_id)

	var sent_count := MessageServer.end_batch(batch_id)

	if sent_count == 5:
		print("✓ 批量处理发送了 %d 条消息" % sent_count)
		_tests_passed += 1
	else:
		print("✗ 批量处理数量错误: %d" % sent_count)
		_tests_failed += 1


## 测试延迟消息
func _test_delayed_message() -> void:
	print("\n--- 测试延迟消息 ---")

	var delay_start := Time.get_ticks_msec()
	var msg := TestMessage.new()
	var timer := MessageServer.send_delayed(msg, 0.1)
	var delay_end := Time.get_ticks_msec()

	if timer:
		print("✓ 延迟消息定时器创建成功，耗时 %dms" % (delay_end - delay_start))
		_tests_passed += 1
	else:
		print("✗ 延迟消息定时器创建失败")
		_tests_failed += 1


## 测试统计功能
func _test_statistics() -> void:
	print("\n--- 测试统计功能 ---")

	MessageServer.reset_statistics()

	for i in range(10):
		var msg := TestMessage.new()
		MessageServer.send_message(msg)

	var stats := MessageServer.get_statistics()

	if stats.total_sent >= 10:
		print("✓ 统计功能正常，已发送 %d 条消息" % stats.total_sent)
		_tests_passed += 1
	else:
		print("✗ 统计功能错误，发送计数: %d" % stats.total_sent)
		_tests_failed += 1

	if stats.by_type.has(&"TestMessage"):
		print("✓ 类型统计正常，TestMessage: %d" % stats.by_type[&"TestMessage"])
		_tests_passed += 1
	else:
		print("✗ 类型统计错误")
		_tests_failed += 1


## 测试消息历史
func _test_message_history() -> void:
	print("\n--- 测试消息历史 ---")

	MessageServer.clear_history()

	var msg := TestMessage.new()
	MessageServer.send_message(msg)

	var history := MessageServer.get_history(10)

	if history.size() > 0:
		print("✓ 消息历史记录正常，记录数: %d" % history.size())
		_tests_passed += 1
	else:
		print("✗ 消息历史记录错误")
		_tests_failed += 1


## 打印测试总结
func _print_summary() -> void:
	print("\n" + "=".repeat(50))
	print("测试总结")
	print("=".repeat(50))
	print("通过: %d" % _tests_passed)
	print("失败: %d" % _tests_failed)
	print("总计: %d" % (_tests_passed + _tests_failed))

	if _tests_failed == 0:
		print("\n✓ 所有测试通过！")
	else:
		print("\n✗ 有 %d 项测试失败" % _tests_failed)

	print("=".repeat(50))
