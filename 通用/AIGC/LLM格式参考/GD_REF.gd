# Everything after "#" is a comment.
# A file is a class!
# But, to make the class "public", you must use class_name to expose it! even for itself!
# class would't be accessed by itself via its filename! you need to use class_name to expose it!!!

# 郑重说明： 务必、务必、务必使用缩进！！！不要用四个空格！我看到就来气！

# (optional) icon to show in the editor dialogs:
# @icon("res://path/to/optional/icon.svg")

# @tool 修饰符可以让你得脚本变成“工具脚本”，在编辑器里即可运行。
# 当你继承自EditorScript时，这个是必须的！


# (optional) class definition. 
# 无论你是否定义了类名，你其实都有办法直接访问。
# 每个脚本都是一个类。区别只有“是否可以全局被访问”。
# 即使不class_name声明，你也能用 const SOME_CLASS_NAME := preload("res://XXX.gd")，后，用SOME_CLASS_NAME作为“导入的类”来使用
# 你大可把这个类比到python的import, 这是减少全局命名空间污染的小妙招。
class_name MyClass

# Inheritance:
extends Node2D # You can extedns any class.（except some basic types： String, int, etc...）



# Member variables.
var a = 5
var s = "Hello"
var arr = [1, 2, 3]
var dict = {"key": "value", 2: 3}
var other_dict = {key = "value", other_key = 2}

# 注意： “可变类型” 的类型是 Variant. 限于 Array[xx]、 Dictionary[xx,xx]中定义类型时使用。
# 不允许乱搞字典！
var other_dict_typed :Dictionary[String, Variant]= {key = "value", other_key = 2} 

# 注意， Array和Dictionary不支持嵌套定义类型，比如 , Array[Array[int]]不受支持，Dict同理。

var typed_var: int
var inferred_type := "String" # 用 := 来自动推测类型。 但我还是建议你把类型打上，以防万一。
var typed_inferred_type :String= "String" # 这样才好！

# 常量。
const ANSWER = 42
const THE_NAME = "Charly"

# 你可以用const + preload来模拟 import, 这样能减少全局命名空间的污染。
#const SOME_CLASS_THAT_HAS_NO_CLASS_NAME = preload("./SOMECLASS.gd")
# 比如这样。这样，你就可以像使用其他公开类一，样用 SOME_CLASS_THAT_HAS_NO_CLASS_NAME 使用SOMECLASS.gd。

# Enums.
enum {UNIT_NEUTRAL, UNIT_ENEMY, UNIT_ALLY}
enum Named {THING_1, THING_2, ANOTHER_THING = -1}

# Built-in vector types.
var v2 = Vector2(1, 2)
var v3 = Vector3(1, 2, 3)
var v3_typed := Vector3(1, 2, 3) # 无论何时，尽可能使用类型！我不想看到editor的warning.


# 函数。把Variant设置为类型，即可限定返回类型。务必这么做！ 参数最好也设置类型！
# 注意，目前不支持可变参数，每个函数的输入参数的数量是固定的（你可以设置默认值）。如果想不固定，就输入数组。
func some_function(param1, param2:Variant, param3:int=0) -> Variant:
	const local_const = 5
	
	# 注意，gds不支持一次比较多个函数！！
	# 不允许 if a<b<c
	# 你必须 if a<b and b<c !
	
	#不过，你可以用
	var A :bool= true if param1<local_const else false
	# 来代替
	var A_old:bool
	if param1<local_const:
		A_old = true
	else:
		A_old = false


	if param1 < local_const:
		print(param1)
	elif param2 > 5:
		print(param2)
	else:
		print("Fail!")

	for i in range(20):
		print(i)

	while param2 != 0:
		param2 -= 1

	match param3:
		3:
			print("param3 is 3!")
		_:
			print("param3 is not 3!")

	var local_var = param1 + 3
	return local_var


# 你可以把任何“可调用的玩意”视作callable!
func lambda_show():
	var a_callable := func():
		print("这是一个Callable,虽然看起来像lambda")
		pass
	
	# 然后用这个来调用！
	a_callable.call()
	
	# 你可以对用func定义的公开方法也这么做！
	some_function.call(1,2,3)
	# 等价于
	some_function(1,2,3)
	
	# 但注意，lambda不支持直接用名称调用。你得用xxx.call(args)来调用才行。
	
	pass

# 一个 “#”代表注释。
# 两个 “#” 代表“文档注释”！
# 例如：
## 这里的文本将被添加到 do_something函数的文档里。类似于 /*param XXX, xxx*/，效果类似于jsdoc.
## 按下F1进入文档界面，或者鼠标悬停的函数/变量说明里，会显示我们的文本。格式遵循BBCode.
## 只是，在GDScript里，你得用函数/变量上方/右边的两个## 开头，来表示文档注释。
## 这会增加代码可读性的。请务必这么做。
func do_something():
	print("OK!!!")
	pass

# 不要这样：
func func_with_doc_bad():
	'''这是该函数的说明'''
	pass

# 你要这样：
## 这里是函数的说明！
func func_with_doc_good():
	pass


# static可修饰函数和方法，效果类似于python。static内不允许调用非static成员函数。很熟悉，对吧？
static var AAA = 0
static func DoSomeStaticthing():
	pass


# 你可以用abstract修饰类。内部类也可以修饰！这种类不可以实例化，最适合抽象方法/基类了。
@abstract class SCLASS:
	func dosth(): # 如果你想，你可以定义并实现方法。就像一般的类一样。厉害吧？
		return OK
		
	@abstract func abs_dosth() # 你也可以定义抽象方法，这种方法在子类里必须被实现。


## Functions override functions with the same name on the base/super class.
## If you still want to call them, use "super":
#func something(p1, p2):
	#super(p1, p2)
## It's also possible to call another function in the super class:
#func other_something(p1, p2):
	#super.something(p1, p2)

# 内部类。这里的类不会暴露到全局空间。在外部脚本中，你可以使用 此类的类名.Something 来调用它的某个内部类。
class Something:
	var a = 10


# Constructor。
func _init():
	print("Constructed!")
	var lv = Something.new()
	print(lv.a)


# 某个最佳实践：
