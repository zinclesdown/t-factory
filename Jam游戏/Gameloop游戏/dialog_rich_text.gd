extends RichTextLabel


func DisplayText(textToDisplay:String):
	self.text = textToDisplay
	self.visible_characters = 0
	
	var textLen := self.text.length() 


func _physics_process(delta: float) -> void:
	self.visible_characters += 1
