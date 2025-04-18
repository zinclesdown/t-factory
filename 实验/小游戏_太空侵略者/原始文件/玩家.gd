extends Node2D


@export var bullet_scene:PackedScene

func _shoot_pressed() -> void:
	var bullet := bullet_scene.instantiate()
	self.add_sibling(bullet)
	bullet.global_position = %"射击点".global_position
	


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		self.position += Vector2(-64, 0) * delta
	if Input.is_action_pressed("ui_right"):
		self.position += Vector2(64, 0) * delta

	if Input.is_action_just_pressed("ui_accept"):
		_shoot_pressed()


#func _tick_process(delta: float) -> void:
	#if Input.is_action_pressed("ui_left"):
		#self.position += Vector2(-32, 0)
	#if Input.is_action_pressed("ui_right"):
		#self.position += Vector2(32, 0)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	body.queue_free()
	queue_free()
