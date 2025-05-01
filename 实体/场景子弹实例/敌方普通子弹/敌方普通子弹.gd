extends RigidBody2D


@export var 存在时间 := 0.4

func _ready() -> void:
	get_tree().create_timer(存在时间).timeout.connect(
		func():
			self.queue_free()
	)


func _physics_process(delta: float) -> void:
	get_colliding_bodies()
