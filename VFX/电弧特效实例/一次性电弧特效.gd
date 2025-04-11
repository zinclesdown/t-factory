class_name 一次性电弧特效实例
extends 一次性VFX特效实例

@onready var 特效: MeshInstance2D = $特效


func 初始化特效(攻击源头位置:Vector2, 受击者位置:Vector2):
	self.global_position = (攻击源头位置 + 受击者位置) / 2.0 # 取中点
	特效.mesh.size.x = (受击者位置-攻击源头位置).length()
	
	self.rotation = (受击者位置-攻击源头位置).angle()
