# .dialogue 文件语法参考

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

## 重要注意事项

⚠️ **编译语言警告：** .dialogue 文件是编译型语言，所有跳转目标 (`=> title`) 必须有对应的标题定义 (`~ title`)，否则编译会失败。

⚠️ **缩进要求：** 务必，务必，务必使用制表符（Tab）进行缩进，而不是四个该死的空格！！4个空格会导致无法识别！

## 基础对话结构

### 简单行
```
这是一段对话。
```

### 角色行
```
角色名: 这是带有角色名的对话。
```

### 对话中的变量
```
角色名: 这个值是 {{DialogueState.getvar("player_health")}}。
{{DialogueState.getvar("player_name")}}: 我的名字来自变量。
```

## 响应系统

### 基本响应
```
角色名: 你想做什么？
- 第一个选项
- 第二个选项
- 第三个选项
```

### 条件响应
```
角色名: 你想做什么？
- 第一个选项 [if DialogueState.getvar("has_key") == true]
- 第二个选项 [if DialogueState.getvar("quest_completed")]
- 第三个选项（总是可用）
```

### 嵌套响应
```
角色名: 你好吗？
- 很好
    角色名: 那太好了！
- 不好
    角色名: 很遗憾听到这个。
    - 想谈谈吗？
        角色名: 我在这里听你说。
    - 不想谈
        角色名: 好的，也许以后再说。
```

### 带跳转的响应
```
角色名: 选择你的路径：
- 去森林 => forest_title
- 去城堡 => castle_title
- 结束对话 => END
```

## 随机化

### 随机行
```
% 角色名: 这可能会被说出。
% 角色名: 或者可能会说出这个。
% 角色名: 有多个选项。
```

### 加权随机行
```
%3 角色名: 这有 60% 的概率。
%2 角色名: 这有 40% 的概率。
%1 角色名: 这有 20% 的概率。
```

### 随机组
```
% 第1组选项
% 第1组选项

% 第2组选项
% 这也是第2组
```

### 随机块
```
%
    角色名: 这是一个随机块。
    角色名: 如果选择，两行都会播放。
% 角色名: 这是一个替代选项。
```

## 条件流程

### If/Else 语句
```
if DialogueState.getvar("player_level") >= 10
    角色名: 玩家等级是 10 或更多。
elif DialogueState.getvar("player_level") == 5
    角色名: 玩家等级正好是 5。
else
    角色名: 玩家等级是其他值。
```

### 内联条件
```
角色名: 我已经做过这个 [if DialogueState.getvar("already_done")]又一次[/if]。
角色名: 你有 {{DialogueState.getvar("item_count")}} [if DialogueState.getvar("item_count") == 1]个物品[else]个物品[/if]。
```

### Match 语句
```
match DialogueState.getvar("player_level")
    when 1
        角色名: 等级是 1。
    when > 5
        角色名: 等级大于 5。
    else
        角色名: 等级是其他值。
```

### While 循环
```
while DialogueState.getvar("counter") < 5
    角色名: 计数是 {{DialogueState.getvar("counter")}}。
    do DialogueState.setvar("counter", DialogueState.getvar("counter") + 1)
```

## 变异操作

### Set 语句
```
set DialogueState.setvar("player_health", 100)
set DialogueState.setvar("gold", DialogueState.getvar("gold") + 10)
set DialogueState.setvar("player_health", DialogueState.getvar("player_health") - 5)
```

### Do 语句
```
do DialogueState.setvar("quest_started", true)
do DialogueState.setvar("last_action", "talked_to_npc")
do DialogueState.setvar("game_time", Time.get_datetime_dict_from_system())
```

### 内联变异
```
角色名: 你好 [do DialogueState.setvar("greeting_done", true)]我是 Nathan！
角色名: 看这个[do DialogueState.setvar("effect_triggered", true)]！
```

### 特殊变异
```
do wait(2.0)  # 等待 2 秒
do debug("一些调试消息")
```

## 跳转系统

### 基本跳转
```
=> some_title
=> END
```

### 跳转并返回
```
=>< some_title  # 到达 END 后会返回
```

### 表达式跳转
```
=> {{DialogueState.getvar("next_title")}}
```

### 强制结束
```
=> END!  # 强制结束，忽略跳转链
```

## 标题和标记

### 定义标题
```
~ start
~ chapter_1
~ secret_ending
```

### 导入其他文件
```
import "res://snippets.dialogue" as snippets

~ start
=>< snippets/common_banter
```

## BBCode 和特殊效果

### 自定义 BBCode
```
角色名: [[这个|或者这个|甚至是这个]]  # 随机选择
角色名: [wait=2]  # 暂停 2 秒
角色名: [speed=0.5]  # 半速
角色名: [next=auto]  # 自动继续
```

### 标签
```
角色名: [#happy, #surprised] 你好！
角色名: [#mood=happy] 我感觉很好！
```

## 并发对话
```
角色名: 我在说话。
| 其他: 我也在同时说话！
| 另一个: 我也是！
```

## 状态快捷方式

### 文件级 Using
```
using DialogueState

~ start
角色名: 我可以直接访问 {{property}}。
```

使用 `using DialogueState` 后，你可以直接访问变量而不需要写完整的前缀：
- `{{property}}` 而不是 `{{DialogueState.getvar("property")}}`
- `if property >= 10` 而不是 `if DialogueState.getvar("property") >= 10`
- `set property = value` 而不是 `do DialogueState.setvar("property", value)`

### 空值合并
```
if DialogueState.getvar("optional_value")?.has_method("some_method")
    角色名: 安全的属性访问。
```

## 注释和转义

### 注释
```
# 这是一个注释
```

### 转义
```
\if 这行以 "if" 开头但不是条件
\- 这行以 "-" 开头但不是响应
\~ 这行以 "~" 开头但不是标题
```

## 完整示例

```
using DialogueState

~ start
Nathan: 你好！我看到你有 {{gold}} 个金币。
- 告诉我关于你自己的事
    Nathan: 我是 Nathan，很高兴认识你！
    set met_nathan = true
- 给我看看你的货物 [if met_nathan]
    => shop
- 离开 => END

~ shop
Nathan: 这是我有的东西：
%3 Nathan: 我有一些不错的剑。
%2 Nathan: 我有药水和卷轴。
%1 Nathan: 我有稀有物品。
- 买剑 => buy_sword
- 买药水 => buy_potion
- 算了 => start

~ buy_sword
if gold >= 100
    set gold = gold - 100
    set has_sword = true
    Nathan: 这是你的剑！ [do play_sound("coins")]
else
    Nathan: 你没有足够的金币。
    set purchase_failed = true
=> shop
```

## 语法总结

| 语法 | 用途 |
|------|------|
| `文本` | 简单对话行 |
| `角色名: 文本` | 角色对话 |
| `- 选项` | 响应选项 |
| `- 选项 [if 条件]` | 条件响应 |
| `% 文本` | 随机行 |
| `%N 文本` | 加权随机行 |
| `if 条件` | 条件块 |
| `else` | 替代条件 |
| `elif 条件` | 附加条件 |
| `match 变量` | 模式匹配 |
| `while 条件` | 循环直到为真 |
| `set 变量 = 值` | 设置变量 |
| `do 方法()` | 调用方法 |
| `=> 标题` | 跳转到标题 |
| `=>< 标题` | 跳转并返回 |
| `=> END` | 结束对话 |
| `=> END!` | 强制结束 |
| `~ 标题` | 定义标题 |
| `import "文件" as 名称` | 导入文件 |
| `using DialogueState` | 状态快捷方式 |
| `{{变量}}` | 变量插值（需要 using） |
| `[if 条件]文本[/if]` | 内联条件（需要 using） |
| `set 变量 = 值` | 变量设置（需要 using） |
| `do 方法()` | 方法调用 |
| `{{DialogueState.getvar("变量")}}` | 变量插值（完整形式） |
| `[if DialogueState.getvar("条件")]文本[/if]` | 内联条件（完整形式） |
| `[do DialogueState.setvar("变量", 值)]` | 内联变异（完整形式） |
| `[#标签]` | 行标签 |
| `[#键=值]` | 带值的标签 |
| `[[选项1\|选项2\|选项3]]` | 随机选择 |
| `[wait=N]` | 等待秒数 |
| `[speed=N]` | 速度倍数 |
| `[next=N]` | 自动继续 |
| `\关键词` | 转义关键词 |