class_name 可放置建筑层实例
extends TileMapLayer

## 所有建筑物都放在此层。


## 获取构筑物所在根位置
var _构筑物根位置信息 :Dictionary = {} 
#var _构筑物根位置信息 :Dictionary[构筑物场景实例, Vector2i] = {} 

## 通过位置，索引构筑物。 注意：可能是多对一！
var _位置到构筑物的映射字典: Dictionary = {} 
#var _位置到构筑物的映射字典: Dictionary[Vector2i, 构筑物场景实例] = {} 

## 这些地方不可以放置构筑物！
var _场景决定的不可放置区域:Array[Vector2i] = []



#region 调试
var DEBUG_PRINT_ENABLED := false

func debug_print(input_str:String) -> void:
	if DEBUG_PRINT_ENABLED:
		print_rich(input_str)

#endregion



#region 原子方法

## TEST HACK 最好防止重复加入，
## 返回是否成功加入场景。假设被占据，则返回false
## 仅在数据层面操作，不涉及场景变换。
func 尝试在数据意义上将构筑物加入场景指定位置_Atom(构筑物:构筑物场景实例, 位置:Vector2i) -> bool:
	# 首先判断是否空间被占据。如果已经被占据，那就返回false
	if not 是否可在位置放置构筑物实例_Atom(构筑物, 位置):
		return false
	
	# 接下来没有被占据，执行放置操作。
	_构筑物根位置信息[构筑物] = 位置 # 先放到根位置信息里
	
	# 再设置位置-构筑物索引
	for coord:Vector2i in 构筑物.获取全局占据的空间格子(位置):
		_位置到构筑物的映射字典[coord] = 构筑物
	
	debug_print("构筑物放置完毕！")
	return true



## TEST
## 仅在数据意义上操作（操作两个字典），不影响场景信息。
func 尝试在数据意义上移除指定位置的构筑物_Atom(位置:Vector2i) -> bool:
	# 首先查看指定位置有没有构筑物
	if not _位置到构筑物的映射字典.has(位置):
		return false
	# 找到构筑物根位置，则调用Atom方法。
	return 尝试在数据意义上将构筑物移除场景_Atom(_位置到构筑物的映射字典[位置])



## TEST
## 返回是否成功移除。假设没有构筑物，则返回false。
## 仅移除数据，不移除场景。
func 尝试在数据意义上将构筑物移除场景_Atom(构筑物:构筑物场景实例) -> bool:
	# 判断位置是否有构筑物。若无，则返回失败。
	if not _构筑物根位置信息.has(构筑物):
		debug_print("构筑物不存在于地图里。跳过。")
		return false
	
	# 移除位置到构筑物的映射字典。
	for coord:Vector2i in 构筑物.获取全局占据的空间格子(_构筑物根位置信息[构筑物]):
		_位置到构筑物的映射字典.erase(coord) 
	
	# 然后移除根位置信息
	_构筑物根位置信息.erase(构筑物) 
	return true



## 获取指定位置的构筑物。不限于根位置。
func 获取占据指定位置的构筑物_Atom(位置: Vector2i) -> 构筑物场景实例:
	if _位置到构筑物的映射字典.has(位置):
		return _位置到构筑物的映射字典.get(位置)
	return null



## 是否可以把实例放置在某个位置上？会根据根位置进行判断。
func 是否可在位置放置构筑物实例_Atom(实例:构筑物场景实例, 放置位置:Vector2i)->bool:
	var 实例可能占据的全局位置列表 :Array[Vector2i]= 实例.获取全局占据的空间格子(放置位置)
	for Pos:Vector2i in 实例可能占据的全局位置列表:
		if 位置是否存在构筑物实例_Atom(Pos)==true:
			debug_print("此位置已存在其他实例。")
			return false
		if 位置是否是不可放置区域_Atom(Pos)==true:
			debug_print("此位置不可用于放置，由于场景。")
	return true



## 检查某个位置是否“被其他构筑物所占据了”。
func 位置是否存在构筑物实例_Atom(位置:Vector2i) -> bool:
	if _位置到构筑物的映射字典.has(位置):
		debug_print("此位置被占据了。")
		return true
	return false



## 检查某个位置是否是场景规定的不可放置区域
func 位置是否是不可放置区域_Atom(位置:Vector2i) -> bool:
	if _场景决定的不可放置区域.has(位置):
		debug_print("由于场景设置，该位置不可放置。")
		return true
	return false


#endregion
