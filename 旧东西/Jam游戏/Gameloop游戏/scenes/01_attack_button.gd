extends Button

signal attackFinished()

## 这是一个会不断增加/然后退回原样的按钮。

var isActivated := false
var progressDelta := 100


func _ready() -> void:
	#isActivated = true
	(find_child("ProgressBar") as ProgressBar).value = 0
	pressed.connect(
		func() -> void:
		isActivated = true
	)


func _process(delta: float) -> void:
	if isActivated:
		var progressBar := find_child("ProgressBar") as ProgressBar
		progressBar.value += delta * progressDelta

		if progressBar.value >= 100:
			progressBar.value = 0
			attackFinished.emit()
