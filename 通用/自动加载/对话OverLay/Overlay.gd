class_name 对话Overlay自动加载单例 extends CanvasLayer
## 用于Dialogue Manager的基础对话气泡

@export var next_action:= "ui_accept" ## 用于推进对话的操作
@export var skip_action:= "ui_cancel" ## 用于跳过对话打字效果的操作

var 当前对话资源: DialogueResource
var 临时游戏状态: Array = []
var 区域设置: String = TranslationServer.get_locale()

var 正在等待玩家输入: bool = false
var 即将隐藏对话气球: bool = false

signal 对话开始
signal 对话结束

## 当前对话行
var 当前的对话行: DialogueLine:
	set(value):
		
		if 当前的对话行==null and is_instance_valid(value):
			# 新对话
			对话开始.emit()
		
		
		if value:
			当前的对话行 = value
			应用当前的对话行()
			正处在对话中 = true
		else:
			#queue_free() # 对话已结束，关闭气泡
			当前的对话行 = null
			正处在对话中 = false
			
			# 对话结束
			print("Dialogue Overlay:: 对话结束!")
			对话结束.emit()

var 函数突变冷却计时器: Timer = Timer.new() ## 用于在遇到mutation时延迟隐藏气泡的冷却计时器

@export var 角色名称Label: RichTextLabel ## 显示当前说话角色名称的标签
@export var 对话内容Label: DialogueLabel ## 显示当前对话内容的标签
@export var 回复选项列表: DialogueResponsesMenu ## 响应选项菜单

@export var 玩家名称 := "你"
@export var 覆盖层Camera:Camera2D
@export var 说话者位置锚点:Marker2D
@export var 主viewport: SubViewportContainer


var 玩家位置:Node2D
var 对方位置:Node2D

var 正处在对话中 :bool =false


func _process(_delta: float) -> void:
	if not is_node_ready() or 玩家位置==null or 对方位置==null:
		return

	# 根据主Viewport
	if 正处在对话中==true: 主viewport.show()
	else: 主viewport.hide()

	# 去你妈线性代数, 我就用土方法
	# 直接原封不动在overlay的子视图里搞个新相机\空间,照搬过来就好
	var CAM_POS := 玩家位置.get_viewport().get_camera_2d().global_position #.get_target_position()
	var 相机缩放 := 玩家位置.get_viewport().get_camera_2d().zoom
	
	覆盖层Camera.global_position = CAM_POS
	覆盖层Camera.zoom = 相机缩放
	
	if 当前的对话行 and 当前的对话行.character==玩家名称:
		说话者位置锚点.global_position = 玩家位置.global_position
	else:
		说话者位置锚点.global_position = 对方位置.global_position



func 开始对话(玩家:Node2D, 对方:Node2D, 对话资源:DialogueResource, 标题:="默认对话") -> void:
	玩家位置 = 玩家
	对方位置 = 对方 # 记录位置
	_开始对话(对话资源, 标题)



func _ready() -> void:
	正处在对话中 = false
	DialogueManager.mutated.connect(_on_mutated)
	#Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# 如果响应菜单没有设置下一步操作，则使用此操作
	if 回复选项列表.next_action.is_empty():
		回复选项列表.next_action = next_action

	函数突变冷却计时器.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(函数突变冷却计时器)


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

	角色名称Label.visible = not 当前的对话行.character.is_empty()
	角色名称Label.text = tr(当前的对话行.character, "dialogue")

	对话内容Label.hide()
	对话内容Label.dialogue_line = 当前的对话行

	回复选项列表.hide()
	回复选项列表.responses = 当前的对话行.responses

	# 显示气泡
	正处在对话中 = true
	即将隐藏对话气球 = false

	对话内容Label.show()
	if not 当前的对话行.text.is_empty():
		对话内容Label.type_out()
		await 对话内容Label.finished_typing

	# 等待输入
	if 当前的对话行.responses.size() > 0:
		回复选项列表.show()
	elif 当前的对话行.time != "":
		var time := 当前的对话行.text.length() * 0.02 if 当前的对话行.time == "auto" else 当前的对话行.time.to_float()
		await get_tree().create_timer(time).timeout
		进入下一段对话(当前的对话行.next_id)
	else:
		正在等待玩家输入 = true


## 跳转到下一行
func 进入下一段对话(next_id: String) -> void:
	self.当前的对话行 = await 当前对话资源.get_next_dialogue_line(next_id, 临时游戏状态)


#region 信号的回调函数
func _on_mutation_cooldown_timeout() -> void:
	if 即将隐藏对话气球:
		即将隐藏对话气球 = false
		#对话气球窗体.hide()


func _on_mutated(_mutation: Dictionary) -> void:
	正在等待玩家输入 = false
	即将隐藏对话气球 = true
	函数突变冷却计时器.开始对话(0.1)


## 检测是否需要跳过对话打字效果
func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(当前的对话行):
		return 
	
	if 对话内容Label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			对话内容Label.skip_typing()
			return

	if not 正在等待玩家输入: return
	if 当前的对话行.responses.size() > 0: return

	## 下一对话
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		进入下一段对话(当前的对话行.next_id)
		get_viewport().set_input_as_handled() # 设置已经handled了.
		
	elif event.is_action_pressed("继续对话"):
		进入下一段对话(当前的对话行.next_id)
		get_viewport().set_input_as_handled() # 设置已经handled了.


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	进入下一段对话(response.next_id)


#endregion
