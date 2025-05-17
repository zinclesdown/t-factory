extends CharacterBody2D


func _ready() -> void:
	pass


enum 移动模式 {
	手动操作, # WASD, 手柄
	自动操作 # 交互/导航
}


## 角色可以自由行走，或者被导航。


# TODO
## 角色会被导航到
func 导航移动到指定位置的最合适位置(目标位置:Vector2):
	pass
