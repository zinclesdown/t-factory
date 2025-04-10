# 介绍
“没想好名字” 的，东方主题的 工厂模拟 + 塔防 + 模拟经营 游戏。
使用全中文GDScript抽象开发。

截至目前使用Godot 4.5 Dev2，纯GDScript, 暂定不使用任何 Dotnet 相关技术。


# 命名规范


## 1. 枚举

所有枚举都存放在“Enums”类里。


```gdscript
# 测试.gd
@export var 选项 :Enums.选项 = Enums.选项.选项1


# Enums.gd
enum 选项 {
	选项1
	选项2
	选项3
}

# 每个枚举都会附带一个 enum_to_string() 方法


```
