extends CharacterBody2D

const SPEED := -64

func _ready() -> void:
	self.velocity = Vector2(0, SPEED)
	
	get_tree().create_timer(10.0).timeout.connect(
		queue_free
	)

func _physics_process(_delta: float) -> void:
	move_and_slide()
