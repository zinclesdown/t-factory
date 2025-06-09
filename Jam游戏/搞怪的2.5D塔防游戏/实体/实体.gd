class_name JAM_实体 
extends CharacterBody3D

@export var 图像:Sprite2D

func 可被选择() -> bool:
	return true

var 被选择:bool = false


func _process(delta: float) -> void:
	if 图像 and 图像.material is ShaderMaterial:
		if 被选择 == true:
			(图像.material as ShaderMaterial).set_shader_parameter("thickness", 2.0)
		else:
			(图像.material as ShaderMaterial).set_shader_parameter("thickness", 0.0)
