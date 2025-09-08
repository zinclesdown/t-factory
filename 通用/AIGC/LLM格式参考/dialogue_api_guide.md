# Dialogue Manager GDScript API 参考

## 概述

Dialogue Manager 为在 Godot 游戏中使用 GDScript 集成对话系统提供了全面的 API。本参考涵盖了对话交互的主要类和方法。

## 前置要求

在使用本 API 之前，请确保你已经设置了必要的单例（Autoload）：

### 必需的单例设置
```gdscript
# 项目设置 -> Autoload
# 添加名为 "DialogueState" 的单例
class_name DialogueState extends Node
	var States: Dictionary = {}

	func setvar(key: String, value: Variant) -> void:
		States[key] = value

	func getvar(key: String) -> Variant:
		return States.get(key, null)
```

**重要提醒：** 如果忘记设置此单例，对话系统将无法正常工作。所有变量存储都必须通过 `DialogueState.setvar()` 和 `DialogueState.getvar()` 进行，不要直接操作 `States` 字典。

⚠️ **缩进要求：** 务必，务必，务必使用制表符（Tab）进行缩进，而不是四个该死的空格！！4个空格会导致无法识别！

## DialogueManager (全局单例)

### 信号

```gdscript
# 对话开始时发出
dialogue_started(resource: DialogueResource)

# 传递标题标记时发出
passed_title(title: String)

# 找到对话行时发出
got_dialogue(line: DialogueLine)

# 变异即将运行时发出
mutated(mutation: Dictionary)

# 对话结束时发出
dialogue_ended(resource: DialogueResource)
```

### 方法

#### 显示对话气球

```gdscript
# 显示配置的对话气球
func show_dialogue_balloon(resource: DialogueResource, title: String = "", extra_game_states: Array = []) -> Node

# 显示特定的对话气球场景
func show_dialogue_balloon_scene(balloon_scene: Node | String, resource: DialogueResource, title: String = "", extra_game_states: Array = []) -> Node

# 显示示例气球
func show_example_dialogue_balloon(resource: DialogueResource, title: String = "", extra_game_states: Array = []) -> CanvasLayer
```

**用法：**
```gdscript
# 简单对话
var balloon = DialogueManager.show_dialogue_balloon(load("res://dialogue.dialogue"), "start")

# 带额外游戏状态的自定义气球
var custom_balloon = DialogueManager.show_dialogue_balloon_scene(preload("res://balloon.tscn"), resource, "start", [self, game_state])
```

#### 获取下一对话行

```gdscript
func get_next_dialogue_line(resource: DialogueResource, key: String = "", extra_game_states: Array = [], mutation_behaviour: MutationBehaviour = MutationBehaviour.Wait) -> DialogueLine
```

**必须与 `await` 一起使用**

**用法：**
```gdscript
# 获取第一行
var dialogue_line = await DialogueManager.get_next_dialogue_line(resource, "start")

# 使用 ID 获取下一行
dialogue_line = await DialogueManager.get_next_dialogue_line(resource, dialogue_line.next_id)

# 带额外游戏状态
dialogue_line = await DialogueManager.get_next_dialogue_line(resource, "start", [self, game_state])
```

**变异行为：**
- `MutationBehaviour.Wait` - 等待变异完成（默认）
- `MutationBehaviour.DoNoWait` - 运行变异但不等待
- `MutationBehaviour.Skip` - 完全跳过变异

#### 运行时创建资源

```gdscript
func create_resource_from_text(text: String) -> DialogueResource
```

**用法：**
```gdscript
var resource = DialogueManager.create_resource_from_text("~ start\n角色名: 你好！")
var line = await resource.get_next_dialogue_line("start")
```

## DialogueLine

### 属性

```gdscript
# 行标识
id: String                    # 唯一行 ID
next_id: String               # 下一行的 ID

# 内容
character: String             # 角色名（或为空）
text: String                  # 对话文本
tags: PackedStringArray       # 行标签
translation_key: String       # 翻译键

# 交互性
responses: Array[DialogueResponse]  # 可用响应
concurrent_lines: Array[DialogueLine]  # 同时显示的行
```

### 用法示例

```gdscript
var line = await DialogueManager.get_next_dialogue_line(resource, "start")

print("角色: ", line.character)
print("文本: ", line.text)
print("标签: ", line.tags)

# 处理响应
for response in line.responses:
    if response.is_allowed:
        print("选项: ", response.text)
```

## DialogueResponse

### 属性

```gdscript
# 响应标识
id: String                    # 唯一响应 ID
next_id: String               # 如果选择，下一行的 ID

# 内容
character: String             # 角色名（或为空）
text: String                  # 响应文本
tags: PackedStringArray       # 响应标签
translation_key: String       # 翻译键

# 条件
is_allowed: bool             # 响应是否可用
condition_as_text: String    # 原始条件字符串
```

### 用法示例

```gdscript
var line = await DialogueManager.get_next_dialogue_line(resource, "start")

for response in line.responses:
    if response.is_allowed:
        print(response.text, " -> ", response.next_id)
        
        # 处理玩家选择
        if selected_response == response:
            var next_line = await DialogueManager.get_next_dialogue_line(resource, response.next_id)
```

## DialogueLabel 节点

### 导出变量

```gdscript
seconds_per_step: float = 0.02                    # 打字速度
pause_at_characters: String = ".?!"               # 自动暂停字符
skip_pause_at_character_if_followed_by: String = ")\""  # 这些字符后不暂停
skip_pause_at_abbreviations: Array = ["Mr", "Mrs", "Ms", "Dr", "etc", "ex"]
seconds_per_pause_step: float = 0.3               # 暂停持续时间
```

### 信号

```gdscript
spoke(letter: String, letter_index: int, speed: float)  # 字母已打出
paused_typing(duration: float)                       # 打字已暂停
started_typing()                                    # 打字已开始
skipped_typing()                                    # 打字已跳过
finished_typing()                                   # 打字已完成
```

### 方法

```gdscript
func type_out() -> void    # 开始打字动画
func skip_typing() -> void # 立即跳到结尾
```

### 用法示例

```gdscript
@onready var dialogue_label = $DialogueLabel

func show_dialogue_line(line: DialogueLine):
    dialogue_label.dialogue_line = line
    dialogue_label.type_out()
    
    # 等待打字完成
    await dialogue_label.finished_typing
    
    # 显示响应
    show_responses(line.responses)
```

## 完整实现示例

```gdscript
extends Node

@onready var dialogue_label = $DialogueLabel
@onready var response_container = $Responses

var current_resource: DialogueResource
var current_line: DialogueLine

func start_dialogue(resource_path: String, title: String = "start"):
    current_resource = load(resource_path)
    await show_next_line(title)

func show_next_line(key: String = ""):
    if key == "":
        key = current_line.next_id if current_line else "start"
    
    current_line = await DialogueManager.get_next_dialogue_line(current_resource, key, [self])
    
    if current_line.is_empty():
        end_dialogue()
        return
    
    # 显示对话行
    dialogue_label.dialogue_line = current_line
    dialogue_label.type_out()
    await dialogue_label.finished_typing()
    
    # 如果有响应则显示
    if current_line.responses.size() > 0:
        show_responses()
    else:
        # 延迟后自动继续
        await get_tree().create_timer(1.0).timeout
        await show_next_line()

func show_responses():
    # 清除现有响应
    for child in response_container.get_children():
        child.queue_free()
    
    # 创建响应按钮
    for response in current_line.responses:
        if response.is_allowed:
            var button = Button.new()
            button.text = response.text
            button.pressed.connect(_on_response_selected.bind(response))
            response_container.add_child(button)

func _on_response_selected(response: DialogueResponse):
    # 禁用所有响应按钮
    for child in response_container.get_children():
        child.disabled = true
    
    # 使用选择的响应继续
    await show_next_line(response.next_id)

func end_dialogue():
    current_line = {}
    current_resource = null
    dialogue_label.text = ""
    for child in response_container.get_children():
        child.queue_free()

# 对话可以调用的示例游戏状态方法
func add_item(item_name: String):
    print("添加物品: ", item_name)
    DialogueState.setvar("last_item_added", item_name)

func set_met_nathan(value: bool):
    print("遇见 Nathan: ", value)
    DialogueState.setvar("met_nathan", value)
```

## 游戏状态集成

### 设置游戏状态

```gdscript
# 游戏状态管理示例（配合 DialogueState 使用）
extends Node

signal item_added(item_name: String)
signal health_changed(amount: int)

func add_item(item_name: String):
    # 获取现有物品列表或创建新列表
    var inventory = DialogueState.getvar("inventory", [])
    inventory.append(item_name)
    DialogueState.setvar("inventory", inventory)
    emit_signal("item_added", item_name)

func take_damage(amount: int):
    var current_health = DialogueState.getvar("health", 100)
    current_health -= amount
    DialogueState.setvar("health", current_health)
    emit_signal("health_changed", -amount)

func heal(amount: int):
    var current_health = DialogueState.getvar("health", 100)
    current_health = min(current_health + amount, 100)
    DialogueState.setvar("health", current_health)
    emit_signal("health_changed", amount)
```

### 使用额外游戏状态

```gdscript
# 多个游戏状态
var player_state = PlayerState.new()
var quest_state = QuestState.new()

# 传递给对话管理器
var line = await DialogueManager.get_next_dialogue_line(
    resource, 
    "start", 
    [player_state, quest_state, self]
)
```

**注意：** 在 .dialogue 文件中使用 `using DialogueState` 可以简化变量访问语法。

## 高级模式

### 自定义当前场景

```gdscript
func _ready():
    # 设置自定义当前场景函数
    DialogueManager.get_current_scene = Callable(self, "_get_current_scene")

func _get_current_scene() -> Node:
    # 返回你的自定义当前场景
    return get_node("/root/SceneManager").current_scene
```

### 对话事件

```gdscript
func _ready():
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
    DialogueManager.got_dialogue.connect(_on_got_dialogue)
    DialogueManager.mutated.connect(_on_mutated)

func _on_dialogue_started(resource: DialogueResource):
    print("对话开始: ", resource.resource_path)

func _on_dialogue_ended(resource: DialogueResource):
    print("对话结束: ", resource.resource_path)

func _on_got_dialogue(line: DialogueLine):
    print("获得对话: ", line.text)

func _on_mutated(mutation: Dictionary):
    print("变异: ", mutation)
```

### 动态对话生成

```gdscript
func create_dynamic_dialogue(character_name: String, messages: Array) -> DialogueResource:
    var text = "~ start\n"
    
    for i in range(messages.size()):
        text += character_name + ": " + messages[i] + "\n"
        if i < messages.size() - 1:
            text += "- 继续\n"
    
    text += "=> END"
    
    return DialogueManager.create_resource_from_text(text)
```

## 最佳实践

1. **始终使用 `await` 与 `get_next_dialogue_line`**
2. **处理空行以检测对话结束**
3. **使用 `extra_game_states` 实现模块化游戏状态**
4. **对话结束时实施适当的清理**
5. **考虑使用信号处理对话事件**
6. **彻底测试响应条件**
7. **使用翻译键支持多语言**

## 错误处理

```gdscript
func safe_get_next_line(resource: DialogueResource, key: String) -> DialogueLine:
    var line = await DialogueManager.get_next_dialogue_line(resource, key)
    
    if line == null or line.is_empty():
        print("对话结束或发生错误")
        return {}
    
    return line
```

本 API 参考提供了使用 GDScript 将 Dialogue Manager 集成到你的 Godot 游戏中所需的所有信息。