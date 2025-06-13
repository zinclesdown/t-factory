abstract class_name JAM_实体 
extends CharacterBody3D

@export var 图像:Sprite2D


@export var 生命 :int = 100

func 可被选择() -> bool:
	return true


func _process(_delta: float) -> void:
	if 图像 and 图像.material is ShaderMaterial:
		if is_in_group("被高亮物") == true:
			(图像.material as ShaderMaterial).set_shader_parameter("thickness", 2.0)
			(图像.material as ShaderMaterial).set_shader_parameter("clr", Color.WHITE)
		elif is_in_group("被选择物") == true:
			(图像.material as ShaderMaterial).set_shader_parameter("thickness", 2.0)
			(图像.material as ShaderMaterial).set_shader_parameter("clr", Color.YELLOW)
		else:
			(图像.material as ShaderMaterial).set_shader_parameter("thickness", 0.0)
			(图像.material as ShaderMaterial).set_shader_parameter("clr", Color.WHITE)


func _to_string() -> String:
	return "<%s: %05d>" % [self.name,  hash(self) % 10000]


func 被命中(攻击:Dictionary) -> void:
	self.生命 -= 攻击.get('伤害', 0)
	self.生命 = clampi(生命,0, 生命)
	if 生命 == 0:
		queue_free()
	return
