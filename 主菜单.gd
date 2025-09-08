extends Control

## 主菜单控制器
## 游戏的入口界面

func _ready() -> void:
	# 检查是否有存档
	_检查存档状态()
	
	# 测试autoload是否正常工作
	_测试_autoload()

func _检查存档状态() -> void:
	# TODO: 检查存档文件是否存在
	var continue_button = $按钮容器/继续游戏按钮
	continue_button.disabled = true  # 暂时禁用，等存档系统实现

func _测试_autoload() -> void:
	print("=== 测试Autoload系统 ===")
	
	# 测试资源管理器
	if has_node("/root/资源管理器"):
		print("✓ 资源管理器 加载成功")
	else:
		print("✗ 资源管理器 加载失败")
	
	# 测试对话组件
	if has_node("/root/对话组件"):
		print("✓ 对话组件 加载成功")
	else:
		print("✗ 对话组件 加载失败")
	
	# 测试全局Toast层
	if has_node("/root/全局Toast层"):
		print("✓ 全局Toast层 加载成功")
	else:
		print("✗ 全局Toast层 加载失败")
	
	# 测试对话状态
	if has_node("/root/DialogueState"):
		print("✓ DialogueState 加载成功")
	else:
		print("✗ DialogueState 加载失败")
	
	# 测试插件autoload
	if has_node("/root/DialogueManager"):
		print("✓ DialogueManager 加载成功")
	else:
		print("✗ DialogueManager 加载失败")
	
	if has_node("/root/PhantomCameraManager"):
		print("✓ PhantomCameraManager 加载成功")
	else:
		print("✗ PhantomCameraManager 加载失败")
	
	if has_node("/root/ImGuiRoot"):
		print("✓ ImGuiRoot 加载成功")
	else:
		print("✗ ImGuiRoot 加载失败")

func _on_start_game_pressed() -> void:
	print("开始游戏按钮被点击")
	# TODO: 加载游戏场景
	get_tree().change_scene_to_file("res://场景/主场景/游戏场景.tscn")

func _on_continue_game_pressed() -> void:
	print("继续游戏按钮被点击")
	# TODO: 加载存档并进入游戏

func _on_settings_pressed() -> void:
	print("设置按钮被点击")
	# TODO: 打开设置界面

func _on_exit_game_pressed() -> void:
	print("退出游戏按钮被点击")
	get_tree().quit()