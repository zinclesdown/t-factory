class_name 放置游戏
extends Node

## This is the main Game Controller script. all game logics are written here.
## It's a fast prototype. no external language required. 
## I'm tired. I want to use this lang. It's enough.

@export_category("Displayers")
@export var displayerLabel: Label

@export_category("Timers")
@export var mainTickTimer: Timer
@export var farmTickTimer: Timer
@export var battleTickTimer: Timer

@export_category("Times")
@export var MainTickTime: float = 0.2 # Seconds. to tick.
@export var FarmTickTime: float = 0.5 # Seconds. to tick.
@export var BattleTickTime: float = 1.0 # Seconds. to tick.

var Player: Dictionary = {
	life = 10,
	lifeMax = 10,

	damage = 10,
	accuracy = 10, # Hit possibility = ACC / (ACC + DODGE)
	dodge = 10
}

var Inventory: Dictionary = {
	money = 0,

}

## Player's litte Town. 
var Base: Dictionary = {
	human = 0,
	humanResource = 0,
	fuelResoource = 0, # Fuel.
	foodResource = 0,
	constructResource = 0,
	magicResource = 0,
	techResource = 0,
}

var Farm := {
	vegetables = 0,
}

var CurEnemy := {
	hasEnemy = false,
	life = 0,
	lifeMax = 10,

	damage = 10,
	accuracy = 10, # Hit possibility = ACC / (ACC + DODGE)
	dodge = 10

}


# 测试用游戏
func _ready() -> void:
	assert(displayerLabel, "You forgot to assign displayerLabel export!")

	assert(mainTickTimer, "You forgot to assign tickTimer export!")
	assert(farmTickTimer, "You forgot to assign tickTimer export!")
	assert(battleTickTimer, "You forgot to assign tickTimer export!")

	mainTickTimer.timeout.connect(_onMainTickTimerTimeout)
	farmTickTimer.timeout.connect(_onFarmTickTimerTimeout)
	battleTickTimer.timeout.connect(_onBattleTickTimerTimeout)

	mainTickTimer.one_shot = false
	farmTickTimer.one_shot = false
	battleTickTimer.one_shot = false

	mainTickTimer.start(MainTickTime)
	farmTickTimer.start(FarmTickTime)
	battleTickTimer.start(BattleTickTime)


func _process(_delta: float) -> void:
	_updateLabel()


func BuidFarm():
	pass


func _updateLabel() -> void:
	#if Engine.get_frames_drawn() % 20 != 0:
		#return

	displayerLabel.text = ""
	displayerLabel.text += StringMethods.StringProgressBar(1 - mainTickTimer.time_left / MainTickTime, 30) + "\n"
	displayerLabel.text += StringMethods.GetDictStr(Player, "Player") + "\n"
	displayerLabel.text += StringMethods.GetDictStr(Inventory, "Inventory") + "\n"
	displayerLabel.text += StringMethods.GetDictStr(Base, "Base") + "\n"


# Main Loop.
func _onMainTickTimerTimeout() -> void:
	pass
	#_updateLabel()


# Farm Loop.
func _onFarmTickTimerTimeout() -> void:
	pass


# Battle Loop.
func _onBattleTickTimerTimeout() -> void:
	if CurEnemy.get("hasEnemy", false) == false:
		print("No Enemy in spot. Ignoring...")
		return

	var enemyDodge: float = CurEnemy.get("dodge", 0)
	var enemyAcc: float = CurEnemy.get("accuracy", 0)
	var enemyDamage: float = Player.get("damage", 0)

	var playerDodge: float = Player.get("dodge", 0)
	var playerAcc: float = Player.get("accuracy", 0)
	var playerDamage: float = Player.get("damage", 0)

	var playerHitSuccessPossibility: float = playerAcc / (playerAcc + enemyDodge)
	var enemyHitSuccessPossibility: float = enemyAcc / (enemyAcc + playerDodge)

	# Start Round!

	# Player's Attack!
	if randf() < playerHitSuccessPossibility:
		CurEnemy["life"] -= playerDamage

		if CurEnemy["life"] <= 0:
			CurEnemy["life"] = 0
			_onEnemyDefeated()
			return # You defeated the enemy. great.

	# Enemy's Attack! (if you didn't defeated the enemy.)
	if randf() < enemyHitSuccessPossibility:
		Player["life"] -= enemyDamage

		if Player["life"] <= 0:
			Player["life"] = 0
			_onPlayerDefeated()
			return # You got defeated!


func _onEnemyDefeated() -> void:
	print("You've slained the enemy!")


func _onPlayerDefeated() -> void:
	print("You got defeated by enemy!")
