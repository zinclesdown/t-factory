extends Container

@export var 文本容器:RichTextLabel

func 初始化(文本, TTL:=2.0):
	文本容器.text = 文本
	
	
	var init_tween := create_tween()
	init_tween.set_trans(Tween.TRANS_QUAD)
	init_tween.tween_method(
		func(value):(material as ShaderMaterial).set_shader_parameter("fadeout_progress", value),
		1.0, 0.0, 0.2
	)
	
	
	self.get_tree().create_timer(TTL).timeout.connect(
		func():
			var exit_tween := create_tween()
			exit_tween.set_trans(Tween.TRANS_QUAD)
			exit_tween.tween_method( # 设置退场动画
				func(value):(material as ShaderMaterial).set_shader_parameter("fadeout_progress", value),
				0.0, 1.0, 0.5
			)
			exit_tween.tween_callback(queue_free)
	)
	
