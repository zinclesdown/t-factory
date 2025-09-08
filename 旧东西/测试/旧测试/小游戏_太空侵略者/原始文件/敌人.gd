extends Node2D

@onready var shoot_timer: Timer = $ShootTimer

@export var time_min := 0
@export var time_max := 20

@export var enemy_bullet_scene :PackedScene

func _ready() -> void:
	shoot_timer.start( randf_range(time_min, time_max) )
	#shoot_timer.time_left
	#shoot_timer.time_left

func _on_shoot_timer_timeout() -> void:
	var bullet := enemy_bullet_scene.instantiate()
	self.add_sibling(bullet)
	bullet.global_position = self.global_position
	
	await get_tree().process_frame
	shoot_timer.start( randf_range(time_min, time_max) )


func _on_hurtbox_body_entered(body: Node2D) -> void:
	body.queue_free()
	self.queue_free()
