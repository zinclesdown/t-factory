@tool
extends RichTextLabel

#@export_tool_button("Update") var updateButton := func() -> void:
	#push_color(Color.REBECCA_PURPLE)
	#append_text("Hello world!")
	#pop_all()
	#
	#append_text("Hi there.")
	#
	#return


func _ready() -> void:
	meta_hover_ended.connect(onMetaHoverEnd)
	meta_hover_started.connect(onMetaHoverStart)


func _process(_delta: float) -> void:
	pass


func onMetaHoverStart(meta):
	recolorMeta(meta)


func onMetaHoverEnd(meta):
	pass


func SetColor():
	pass

## We set color ahead of meta.
## for example, [color=xxx][url meta=xxx]XXXX[/url][/color]
func recolorMeta(meta: Variant, color:String="yellow") -> void:
	print("Trying to recolor meta!")
	var rawText := text
	var metaBegin := text.find("[url")
	rawText = rawText.insert(metaBegin, "[color=yellow]")

	var metaEnd := text.find("[/url]", metaBegin) + len("[/url]")
	rawText = rawText.insert(metaEnd, "[/color]")
	
	print(metaBegin, metaEnd)
	text = rawText
	
	print(text)
