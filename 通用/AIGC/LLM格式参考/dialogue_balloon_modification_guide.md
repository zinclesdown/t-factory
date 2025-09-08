# Dialogue Balloon 修改指南

## 概述

本文档说明如何修改和自定义 Dialogue Manager 的示例对话气球 (Example Balloon)。气球是用户与对话系统交互的 UI 界面。

## 前置要求

在使用本插件之前，请确保你已经设置了必要的单例（Autoload）：

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

⚠️ **编译语言警告：** .dialogue 文件是编译型语言，所有跳转目标 (`=> title`) 必须有对应的标题定义 (`~ title`)，否则编译会失败。

### Using 语句
在 .dialogue 文件开头使用 `using DialogueState` 可以简化变量访问语法：
- 使用 `{{variable}}` 而不是 `{{DialogueState.getvar("variable")}}`
- 使用 `set variable = value` 而不是 `do DialogueState.setvar("variable", value)`
- 使用 `if variable >= 10` 而不是 `if DialogueState.getvar("variable") >= 10`

## 文件结构

```
addons/dialogue_manager/example_balloon/
├── example_balloon.gd          # 主脚本
├── example_balloon.tscn        # 主场景
├── small_example_balloon.tscn  # 小屏幕版本
└── ExampleBalloon.cs           # C# 版本（忽略）
```

## 核心修改点

### 1. 视觉外观修改

#### 场景文件修改 (`example_balloon.tscn`)

**主题样式：**
```gdscript
# 修改主题颜色和字体
[node name="Balloon" type="Control"]
theme = SubResource("Theme_qq3yp")  # 修改主题资源
```

**样式资源：**
```gdscript
# 修改背景样式
[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_qkmqt"]
bg_color = Color(0, 0, 0, 1)           # 背景颜色
border_color = Color(0.6, 0.6, 0.6, 1) # 边框颜色
corner_radius_top_left = 5              # 圆角
```

**布局调整：**
```gdscript
# 修改边距
[node name="MarginContainer"]
offset_top = -219.0  # 调整垂直位置
```

#### 脚本中的视觉修改 (`example_balloon.gd`)

**导出变量：**
```gdscript
# 添加可配置的视觉属性
@export var balloon_color: Color = Color(0, 0, 0, 1)
@export var text_color: Color = Color(1, 1, 1, 1)
@export var character_color: Color = Color(1, 1, 1, 0.5)
@export var font_size: int = 20
```

**应用样式：**
```gdscript
func _ready():
    # 应用自定义样式
    balloon.modulate = balloon_color
    dialogue_label.add_theme_color_override("default_color", text_color)
    character_label.add_theme_color_override("default_color", character_color)
```

### 2. 行为修改

#### 输入处理修改

**修改输入动作：**
```gdscript
@export var next_action: StringName = &"ui_accept"    # 继续对话
@export var skip_action: StringName = &"ui_cancel"     # 跳过打字
```

**自定义输入逻辑：**
```gdscript
func _on_balloon_gui_input(event: InputEvent) -> void:
    # 修改输入检测逻辑
    if event.is_action_pressed("custom_action"):
        # 自定义行为
        pass
```

#### 打字效果修改

**访问 DialogueLabel 属性：**
```gdscript
func _ready():
    # 修改打字速度
    dialogue_label.seconds_per_step = 0.01  # 更快
    dialogue_label.pause_at_characters = ".?!"  # 暂停字符
```

**自定义打字效果：**
```gdscript
func apply_dialogue_line() -> void:
    # 自定义打字行为
    dialogue_label.type_out()
    
    # 添加自定义效果
    if dialogue_line.tags.has("shaky"):
        start_shaky_effect()
```

### 3. 响应系统修改

#### 响应菜单自定义

**修改 `DialogueResponsesMenu` 行为：**
```gdscript
func _ready():
    # 配置响应菜单
    responses_menu.hide_failed_responses = true  # 隐藏失败响应
    responses_menu.next_action = next_action    # 继承输入动作
```

**自定义响应按钮：**
```gdscript
# 在场景中修改响应按钮模板
[node name="ResponseExample" type="Button"]
custom_minimum_size = Vector2(200, 40)  # 修改按钮大小
```

**动态响应创建：**
```gdscript
func apply_dialogue_line() -> void:
    # 自定义响应处理
    for response in dialogue_line.responses:
        if response.tags.has("special"):
            create_special_response(response)
```

### 4. 动画效果

#### 添加动画

**入场动画：**
```gdscript
func start_dialogue():
    balloon.scale = Vector2(0, 0)
    balloon.show()
    
    var tween = create_tween()
    tween.tween_property(balloon, "scale", Vector2(1, 1), 0.3)
    
    apply_dialogue_line()
```

**出场动画：**
```gdscript
func end_dialogue():
    var tween = create_tween()
    tween.tween_property(balloon, "scale", Vector2(0, 0), 0.3)
    await tween.finished
    queue_free()
```

#### 表情动画
```gdscript
func apply_dialogue_line() -> void:
    # 根据标签添加动画
    if dialogue_line.tags.has("happy"):
        play_expression_animation("happy")
    elif dialogue_line.tags.has("angry"):
        play_expression_animation("angry")
```

### 5. 音效和特效

**添加音效：**
```gdscript
@export var typing_sound: AudioStream
@export var next_sound: AudioStream
@export var select_sound: AudioStream

func _ready():
    $AudioStreamPlayer.stream = typing_sound
    
    # 连接信号
    dialogue_label.spoke.connect(_on_letter_typed)
    responses_menu.response_selected.connect(_on_response_selected)

func _on_letter_typed(letter: String):
    if randf() < 0.1:  # 10% 概率播放打字音
        $AudioStreamPlayer.play()
```

### 6. 高级功能

#### 多角色支持
```gdscript
func apply_dialogue_line() -> void:
    # 根据角色改变样式
    match dialogue_line.character:
        "Nathan":
            character_label.modulate = Color.BLUE
        "Enemy":
            character_label.modulate = Color.RED
        _:
            character_label.modulate = Color.WHITE
```

#### 并发对话显示
```gdscript
func apply_dialogue_line() -> void:
    # 显示并发对话
    for concurrent_line in dialogue_line.concurrent_lines:
        create_concurrent_balloon(concurrent_line)
```

#### 自定义变异处理
```gdscript
func _on_mutated(mutation: Dictionary) -> void:
    # 自定义变异效果
    if mutation.has("type"):
        match mutation.type:
            "screen_shake":
                start_screen_shake()
            "flash":
                start_flash_effect()
```

## 创建自定义气球

### 1. 复制和修改

```gdscript
# 1. 复制示例文件
cp example_balloon.gd custom_balloon.gd
cp example_balloon.tscn custom_balloon.tscn

# 2. 修改类名
class_name CustomDialogueBalloon extends CanvasLayer
```

### 2. 重写关键方法

```gdscript
func apply_dialogue_line() -> void:
    # 自定义应用逻辑
    pass

func _on_balloon_gui_input(event: InputEvent) -> void:
    # 自定义输入处理
    pass
```

### 3. 注册自定义气球

```gdscript
# 在项目设置中设置
func _ready():
    DialogueManager.show_dialogue_balloon = Callable(self, "show_custom_balloon")
```

## 调试技巧

### 1. 调试输出
```gdscript
func apply_dialogue_line() -> void:
    print("Line: ", dialogue_line.text)
    print("Character: ", dialogue_line.character)
    print("Responses: ", dialogue_line.responses.size())
    print("Tags: ", dialogue_line.tags)
```

### 2. 可视化调试
```gdscript
func _draw():
    # 绘制调试信息
    draw_string(theme.default_font, Vector2(10, 10), "Next ID: " + dialogue_line.next_id)
```

### 3. 状态监控
```gdscript
func _process(delta):
    if Input.is_key_pressed(KEY_F1):
        print("Current state:")
        print("  Waiting for input: ", is_waiting_for_input)
        print("  Is typing: ", dialogue_label.is_typing)
        print("  Responses visible: ", responses_menu.visible)
```

## 常见修改场景

### 1. 创建 JRPG 风格气球
- 修改为底部居中显示
- 添加角色头像
- 使用固定宽度的文本框
- 添加闪烁的光标效果

### 2. 创建视觉小说风格
- 全屏显示
- 添加角色立绘
- 使用更大的字体
- 添加渐变背景

### 3. 创建 RPG 对话框
- 顶部显示角色名
- 添加边框和背景
- 使用等宽字体
- 添加滚动文本支持

### 4. 创建手机适配版本
- 增大按钮尺寸
- 添加触摸支持
- 调整文本大小
- 优化布局

## 性能优化

### 1. 对象池
```gdscript
# 重用响应按钮而不是每次创建
var button_pool: Array = []

func get_response_button() -> Button:
    if button_pool.size() > 0:
        return button_pool.pop_front()
    return Button.new()
```

### 2. 异步加载
```gdscript
# 预加载资源
@onready var default_font = preload("res://fonts/default.tres")
@onready var sound_effects = preload("res://sounds/dialogue_sounds.tres")
```

### 3. 批量操作
```gdscript
# 批量应用样式
func apply_theme_recursively(node: Node, theme: Theme):
    for child in node.get_children():
        if child is Control:
            child.theme = theme
        apply_theme_recursively(child, theme)
```

## 测试建议

1. **功能测试**：确保所有对话类型都能正确显示
2. **输入测试**：测试各种输入设备的响应
3. **性能测试**：检查长对话的内存使用
4. **兼容性测试**：确保在不同分辨率下正常工作
5. **本地化测试**：验证多语言支持

这个指南提供了修改对话气球的所有关键点，从简单的视觉调整到复杂的功能扩展。