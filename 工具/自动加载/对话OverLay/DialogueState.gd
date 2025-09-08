## Autoload DialogueState
extends Node


var States :Dictionary = {}


func setvar(key, value) -> void:
	States[key] = value


func getvar(key) -> Variant:
	return States.get(key, null)
