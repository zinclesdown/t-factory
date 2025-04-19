extends CanvasLayer

enum Toast位置 {
	右下角
}


@export var 右下角Toast消息预制件 :PackedScene
@onready var 右下角容器: VBoxContainer = %右下角容器

func _ready() -> void:
	右下角容器.get_children().all(func(a): a.queue_free(); return true)


func 发送Toast消息(消息:String, TTL:=2.0, 位置:=Toast位置.右下角):
	var 预制件 := 右下角Toast消息预制件.instantiate()
	右下角容器.add_child(预制件)
	右下角容器.move_child(预制件, 0)
	预制件.初始化(消息, TTL)


func _on_测试发送toast消息_pressed() -> void:
	发送Toast消息("你好,世界! (TTL=1s)")
