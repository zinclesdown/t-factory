abstract class_name JAM_实体 
extends CharacterBody3D

@export var 图像:Sprite3D


@export var 生命 :int = 100

func 可被选择() -> bool:
	return true

func _ready() -> void:
	if is_instance_valid(图像) and 图像 is Sprite3D and 图像.material_override:
		(图像.material_override as ShaderMaterial).set_shader_parameter("time_offset", randf_range(0, 100))

func _process(_delta: float) -> void:
	pass
	if is_instance_valid(图像) and 图像 is Sprite3D and 图像.material_override:
	
	#if is_instance_valid(图像) and 图像.is_node_ready() and 图像.material_override is ShaderMaterial:
		if is_in_group("被高亮物") == true:
			(图像.material_override).set_shader_parameter("outline_thickness", 2.0)
			(图像.material_override).set_shader_parameter("outline_color", Color.WHITE)
		elif is_in_group("被选择物") == true:
			(图像.material_override).set_shader_parameter("outline_thickness", 2.0)
			(图像.material_override).set_shader_parameter("outline_color", Color.YELLOW)
		else:
			(图像.material_override).set_shader_parameter("outline_thickness", 0.0)
			(图像.material_override).set_shader_parameter("outline_color", Color.WHITE)


func _to_string() -> String:
	return "<%s: %05d>" % [self.name,  hash(self) % 10000]


func 被命中(攻击:Dictionary) -> void:
	self.生命 -= 攻击.get('伤害', 0)
	self.生命 = clampi(生命,0, 生命)
	if 生命 == 0:
		queue_free()
	return
