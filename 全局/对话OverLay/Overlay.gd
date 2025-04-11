class_name 对话Overlay自动加载单例 extends Node2D
## 用于Dialogue Manager的基础对话气泡
## BROKEN 定位系统故障!!!!!!


@export var next_action:= "ui_accept" ## 用于推进对话的操作
@export var skip_action:= "ui_cancel" ## 用于跳过对话打字效果的操作


var 当前对话资源: DialogueResource
var 临时游戏状态: Array = []
var 区域设置: String = TranslationServer.get_locale()




var 正在等待玩家输入: bool = false
var 即将隐藏对话气球: bool = false

## 当前对话行
var 当前的对话行: DialogueLine:
	set(value):
		if value:
			当前的对话行 = value
			应用当前的对话行()
		else:
			queue_free() # 对话已结束，关闭气泡


var 函数突变冷却计时器: Timer = Timer.new() ## 用于在遇到mutation时延迟隐藏气泡的冷却计时器

#@export var 说话者位置: Marker2D ## 基础气泡锚点
@export var 对话气球窗体: Control ## 基础气泡锚点



@export var 角色名称Label: RichTextLabel ## 显示当前说话角色名称的标签
@export var 对话内容Label: DialogueLabel ## 显示当前对话内容的标签
@export var 回复选项列表: DialogueResponsesMenu ## 响应选项菜单

@export var 玩家名称 := "你"

var 玩家位置:Node2D
var 对方位置:Node2D



func _process(delta: float) -> void:
	print(玩家位置, 对方位置)
	if not is_node_ready() or 玩家位置==null or 对方位置==null:
		return
	
	## 屏幕中央 到 地图原点 的变换.
	var cam_offset := 玩家位置.get_viewport().get_camera_2d().global_position #.get_target_position()
	var 相机缩放 := 玩家位置.get_viewport().get_camera_2d().zoom
	var 屏幕大小 := Vector2(DisplayServer.window_get_size())
	var 相机大小 :=  Vector2(屏幕大小) / Vector2(相机缩放) 
	#print(玩家位置.())
	
	print(屏幕大小)
	
	## BROKEN FIXME BUG ISSUE 我没搞懂具体该怎么做, 涉及到该死的数学问题
	##
	var s := (屏幕大小-相机大小)/2
	
	var 玩家位置_inversed := (玩家位置.global_position - cam_offset)# + 屏幕大小/2 -s
	var 对方位置_inversed := (对方位置.global_position - cam_offset)# + 屏幕大小/2 -s
	
	#print(玩家位置_inversed, 对方位置_inversed)
	
	if 当前的对话行 and 当前的对话行.character==玩家名称:
		position = 玩家位置_inversed
	else:
		position = 对方位置_inversed





func 开始对话(玩家:Node2D, 对方:Node2D, 对话资源:DialogueResource, 标题="默认对话"):
	# 记录位置
	玩家位置 = 玩家
	对方位置 = 对方
	
	#get_viewport().get_camera_2d()
	
	# 开始
	_开始对话(对话资源, 标题)



func _ready() -> void:
	对话气球窗体.hide()

	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# 如果响应菜单没有设置下一步操作，则使用此操作
	if 回复选项列表.next_action.is_empty():
		回复选项列表.next_action = next_action

	函数突变冷却计时器.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(函数突变冷却计时器)


func _unhandled_input(_event: InputEvent) -> void:
	# 当气泡显示时，只有Balloon被允许处理输入
	get_viewport().set_input_as_handled()

#region 地区和翻译相关


## 检测语言环境变化并更新当前对话行以显示新语言
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and 区域设置 != TranslationServer.get_locale() and is_instance_valid(对话内容Label):
		区域设置 = TranslationServer.get_locale()
		self.当前的对话行 = await 当前对话资源.get_next_dialogue_line(当前的对话行.id)
		if 对话内容Label.visible_ratio < 1:
			对话内容Label.skip_typing()

#endregion


## 开始对话
func _开始对话(对话资源文件: DialogueResource, 对话标题: String="默认对话", 额外游戏状态: Array = []) -> void:
	临时游戏状态 = [self] + 额外游戏状态
	正在等待玩家输入 = false
	当前对话资源 = 对话资源文件
	self.当前的对话行 = await 当前对话资源.get_next_dialogue_line(对话标题, 临时游戏状态)


## 根据新的[DialogueLine]应用对气泡的任何更改
func 应用当前的对话行() -> void:
	函数突变冷却计时器.stop()

	正在等待玩家输入 = false
	#对话气球.focus_mode = Control.FOCUS_ALL
	#对话气球.grab_focus()

	角色名称Label.visible = not 当前的对话行.character.is_empty()
	角色名称Label.text = tr(当前的对话行.character, "dialogue")

	对话内容Label.hide()
	对话内容Label.dialogue_line = 当前的对话行

	回复选项列表.hide()
	回复选项列表.responses = 当前的对话行.responses

	# 显示气泡
	对话气球窗体.show()
	即将隐藏对话气球 = false

	对话内容Label.show()
	if not 当前的对话行.text.is_empty():
		对话内容Label.type_out()
		await 对话内容Label.finished_typing

	# 等待输入
	if 当前的对话行.responses.size() > 0:
		对话气球窗体.focus_mode = Control.FOCUS_NONE
		回复选项列表.show()
	elif 当前的对话行.time != "":
		var time = 当前的对话行.text.length() * 0.02 if 当前的对话行.time == "auto" else 当前的对话行.time.to_float()
		await get_tree().create_timer(time).timeout
		进入下一段对话(当前的对话行.next_id)
	else:
		正在等待玩家输入 = true
		对话气球窗体.focus_mode = Control.FOCUS_ALL
		对话气球窗体.grab_focus()


## 跳转到下一行
func 进入下一段对话(next_id: String) -> void:
	self.当前的对话行 = await 当前对话资源.get_next_dialogue_line(next_id, 临时游戏状态)


#region 信号的回调函数
func _on_mutation_cooldown_timeout() -> void:
	if 即将隐藏对话气球:
		即将隐藏对话气球 = false
		对话气球窗体.hide()


func _on_mutated(_mutation: Dictionary) -> void:
	正在等待玩家输入 = false
	即将隐藏对话气球 = true
	函数突变冷却计时器.开始对话(0.1)


## 检测是否需要跳过对话打字效果
func _on_balloon_gui_input(event: InputEvent) -> void:
	if 对话内容Label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			对话内容Label.skip_typing()
			return

	if not 正在等待玩家输入: return
	if 当前的对话行.responses.size() > 0: return

	# 当没有响应选项时，气泡本身是可点击的
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		进入下一段对话(当前的对话行.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == 对话气球窗体:
		进入下一段对话(当前的对话行.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	进入下一段对话(response.next_id)


#endregion
