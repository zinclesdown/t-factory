extends CanvasLayer

@onready var 矿物label: Label = $资源量显示器/矿物/矿物Label
@onready var 木材label: Label = $资源量显示器/木材/木材Label


func _process(_delta: float) -> void:
	矿物label.text = str(JAM_基地.资源_矿物)
	木材label.text = str(JAM_基地.资源_木材)
