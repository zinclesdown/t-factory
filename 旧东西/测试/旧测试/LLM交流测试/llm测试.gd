extends Node2D

func _ready() -> void:
	var requester := LLMRequester.new()
	requester.init_as_local_ollama()
	
	requester.call_api()
	#requester.
	pass
