extends Node

var curEnemyName := ""
var curEnemyLife := 100
var curEnemyDamage := 10

var playerLife := 100
var playerDamage := 50
var playerName := "Enter Your Name Here."

# =====

# =====


func _ready() -> void:
	% "01AttackButton".hide()

	ActivateGame("01AttackButton")


## 启用游戏。
func ActivateGame(gameName: String) -> Error:
	match gameName:
		"01AttackButton":
			% "01AttackButton".show()

		"00GameBegin":
			print("Game is begin!")
			DisplayText("Test Message, Please Ignore!")
			pass

		_:
			print("ERR!")
			return ERR_DOES_NOT_EXIST
	return OK

# OK
func DisplayText(text: String) -> void:
	%DialogRichText.DisplayText(text)

# maybe ok
func _onScene01AttackFinished() -> void:
	print("敌人受伤: ", playerDamage, ",  敌人剩余血量：", curEnemyLife - playerDamage)
	curEnemyLife -= playerDamage
