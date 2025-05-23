class_name 玩家全局状态

static var _当前操作者玩家全局单例:玩家角色


static func 设置当前玩家角色(玩家:玩家角色) -> void:
	_当前操作者玩家全局单例 = 玩家


enum 操作状态 {
	自由活动,
	对话中,
	交互中,
	建筑中,
}


static func 操作状态_to_string(状态: 操作状态) -> String:
	match 状态:
		操作状态.自由活动:
			return "自由活动"
		操作状态.对话中:
			return "对话中"
		操作状态.交互中:
			return "交互中"
		操作状态.建筑中:
			return "建筑中"
		_:
			assert(false, "不存在的状态!!")
			return "错误!!!"


static var _当前玩家操作状态:操作状态 = 操作状态.自由活动

static func 是自由活动状态()->bool:
	return _当前玩家操作状态 == 操作状态.自由活动

static func 是对话中状态()->bool:
	return _当前玩家操作状态 == 操作状态.对话中

static func 是交互中状态()->bool:
	return _当前玩家操作状态 == 操作状态.交互中

static func 是建筑中状态()->bool:
	return _当前玩家操作状态 == 操作状态.建筑中



static func 操作状态设置为自由活动() -> void:
	_当前玩家操作状态 = 操作状态.自由活动

static func 操作状态设置为对话中() -> void:
	_当前玩家操作状态 = 操作状态.对话中

static func 操作状态设置为交互中() -> void:
	_当前玩家操作状态 = 操作状态.交互中

static func 操作状态设置为建筑中() -> void:
	_当前玩家操作状态 = 操作状态.建筑中


## 当玩家处于“进行建筑” 状态时，游戏可以从玩家手持的蓝图实例获取信息。
static var _当前玩家手持建筑物: 构筑物蓝图实例 = null


static func 设置玩家建筑状态下的手持构筑物蓝图(构筑物蓝图:构筑物蓝图实例) -> void:
	_当前玩家手持建筑物 = 构筑物蓝图
