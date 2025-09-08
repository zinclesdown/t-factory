# GDScript 4.x 参考手册 - Claude Code 提示用版本
# ===============================================================
# 
# 本文件是GDScript 4.x语法的快速参考，专为AI助手设计
# 包含常用的语法结构、最佳实践和注意事项
# 
# 作者：Claude Code
# 版本：2.2
# 更新日期：2025-09-02
# 
# ===============================================================

# 基础语法规则
# ===============================================================

# 注释规则：
# - 单行注释：# 开头
# - 文档注释：## 开头（用于函数/变量说明，支持BBCode格式）
# - 不支持多行注释语法 ''' 或 """

# 缩进规则：
# - 务必使用缩进（制表符或空格，建议4个空格）
# - 缩进表示代码块，类似Python
# - 不要使用大括号 {} 表示代码块

# 变量声明和类型
# ===============================================================

# 基本变量声明
var a = 5                    # 整数
var s = "Hello"              # 字符串
var arr = [1, 2, 3]          # 数组
var dict = {"key": "value"}   # 字典（推荐冒号语法）
var dict_alt = {key = "value"}  # 字典（等号语法，也可用）

# 类型注解（强烈推荐）
var typed_var: int           # 显式类型声明
var inferred_type := "String"  # 类型推断（:=操作符）
var typed_inferred_type: String = "String"  # 完整类型声明

# 注意：可变类型（Array, Dictionary）的类型注解有特殊规则
var typed_array: Array[int] = [1, 2, 3]      # 整数数组
var typed_dict: Dictionary[String, Variant] = {"key": "value"}  # 键值对字典

# 重要限制：
# - 不支持嵌套类型定义，如 Array[Array[int]] 是无效的
# - Dictionary的键类型必须是基本类型（String, int等）

# 常量定义
# ===============================================================
const ANSWER = 42                    # 整数常量
const THE_NAME = "Charly"            # 字符串常量
const PI = 3.14159                   # 浮点数常量

# 使用const + preload模拟导入（减少全局命名空间污染）
const SOME_CLASS = preload("res://path/to/class.gd")
# 然后可以用 SOME_CLASS 访问该类

# 枚举定义
# ===============================================================

# 匿名枚举
enum {UNIT_NEUTRAL, UNIT_ENEMY, UNIT_ALLY}

# 命名枚举
enum Named {THING_1, THING_2, ANOTHER_THING = -1}

# 带文档注释的枚举
## 地牢生成过程中可能遇到的错误类型
enum DungeonError {
    ## 生成成功
    SUCCESS = 0,
    ## 配置参数无效
    INVALID_CONFIG = 1,
    ## 生成过程失败
    GENERATION_FAILED = 2,
}

# 向量类型（Godot内置）
# ===============================================================
var v2 = Vector2(1, 2)           # 2D向量
var v3 = Vector3(1, 2, 3)        # 3D向量
var v3_typed := Vector3(1, 2, 3) # 带类型注解的向量（推荐）

# 函数定义
# ===============================================================

# 基本函数语法
func function_name(param1, param2: int = 0) -> Variant:
    # 函数体
    return param1 + param2

# 带完整文档注释的函数
## 计算两个点之间的欧几里得距离
## @param p1: 第一个点
## @param p2: 第二个点
## @return: 两点之间的直线距离
func calculate_distance(p1: Vector2, p2: Vector2) -> float:
    var dx = p1.x - p2.x
    var dy = p1.y - p2.y
    return sqrt(dx * dx + dy * dy)

# 函数参数规则：
# - 参数数量固定（不支持可变参数）
# - 可以设置默认值
# - 建议为所有参数添加类型注解
# - 建议指定返回类型

# 控制流语句
# ===============================================================

# 条件语句
if condition:
    # 代码块
elif another_condition:
    # 代码块
else:
    # 代码块

# 重要：GDScript不支持链式比较！
# 错误：if a < b < c:
# 正确：if a < b and b < c:

# 三元运算符（使用if表达式）
var result = "positive" if value > 0 else "negative"

# 循环语句
for i in range(20):           # for循环
    print(i)

while condition != 0:         # while循环
    condition -= 1

# match语句（类似switch-case）
match value:
    1:
        print("Value is 1")
    2, 3:                     # 多值匹配
        print("Value is 2 or 3")
    _:
        print("Default case")

# 类和继承
# ===============================================================

# 类定义和继承
class_name MyClass
extends Node2D

# 成员变量
var member_var = 10

# 构造函数
func _init():
    print("Constructed!")

# 静态成员
static var static_var = 0
static func static_method():
    return static_var

# 内部类（不暴露到全局命名空间）
class InnerClass:
    var inner_var = 20
    
    func inner_method():
        return inner_var

# 使用内部类
var inner_instance = InnerClass.new()

# 抽象类和方法
@abstract class AbstractClass:
    func normal_method():
        return "normal"
    
    @abstract func abstract_method()  # 必须在子类中实现

# 信号系统
# ===============================================================

# 信号定义
signal health_changed(new_health)
signal player_died(position, cause)

# 信号发射
health_changed.emit(100)
player_died.emit(Vector2.ZERO, "fall")

# 信号连接（在_ready中）
func _ready():
    health_changed.connect(_on_health_changed)

# 信号处理函数
func _on_health_changed(new_health):
    print("Health changed to: ", new_health)

# Callable和Lambda
# ===============================================================

# Lambda函数（使用func关键字）
var lambda_func = func(x, y):
    return x + y

# 保险起间，你可以使用括号。
var lambda_func = func(x, y):(
    return x + y
)

# 调用lambda
var result = lambda_func.call(5, 3)  # 必须使用.call()方法

# 将实例方法作为Callable传递
var method_callable = some_method
method_callable.call(arg1, arg2)  # 等价于 some_method(arg1, arg2)

# 工具脚本
# ===============================================================

# @tool修饰符使脚本在编辑器中即可运行
@tool
extends EditorScript

# 工具脚本可以访问编辑器API
func _run():
    print("Running in editor")

# 最佳实践和注意事项
# ===============================================================

# 1. 类型安全
# - 始终为变量和函数添加类型注解
# - 使用:=进行类型推断，但显式声明更清晰
# - 避免使用Variant类型，除非必要

# 2. 内存管理
# - GDScript使用引用计数和垃圾回收
# - 使用RefenceCounted基类管理对象生命周期
# - 避免循环引用

# 3. 性能优化
# - 避免在循环中创建新对象
# - 使用缓存减少重复计算
# - 优先使用内置函数而非自定义实现

# 4. 错误处理
# - 使用assert()进行调试检查
# - 使用push_error()和push_warning()记录问题
# - 考虑使用Result模式返回错误信息

# 5. 代码组织
# - 使用内部类组织相关功能
# - 避免全局变量，使用类成员或静态变量
# - 使用文档注释提高代码可读性

# 6. Godot集成
# - 熟悉Godot的节点系统和信号机制
# - 利用内置的向量和数学函数
# - 使用@export变量在编辑器中暴露参数。@export的变量务必定义类型。

# 常见陷阱和解决方案
# ===============================================================

# 1. 链式比较错误
# 错误：if 0 <= x < width:
# 正确：if 0 <= x and x < width:

# 2. 数组类型嵌套
# 错误：Array[Array[int]]
# 解决：使用单层数组或自定义数据结构。Godot目前不支持嵌套定义类型，字典同理。

# 3. 字典键类型
# 错误：Dictionary[Variant, Variant]（性能差）
# 正确：Dictionary[String, int]（明确键类型）

# 4. 对象生命周期
# 问题：RefenceCounted对象过早释放
# 解决：保持引用或使用Node基类


# 5.类型化数组的类型转换：（必须显式转换！）
func _run() -> void:
    print("it's a trap.")

    var arrayA :Array= []
    var arrayB :Array[Array]= []

    # 错误示范
    arrayB = arrayA # 会报错！类型化数组不支持隐式转换！

    # 正确示范
    var tmp_B :Array[Array] = [] # 定义一个目标类型的空数组
    tmp_B.append_array(arrayA) # 然后用append_array将元素全部挪过来
    arrayB = tmp_B # 改变数组索引。

    ## 注意！！Godot数组属于"传引用传递"。上述操作会导致数组指向了不同的内存位置！
    ## 无论何时，你的最小操作单元应该是"对象"。这意味着，无论何时，你都不应该直接引用一个数组。倘若需要外部使用，最好连带方法一起包装在类中。

# 6. 整数除法规范：（必须显式转换为浮点数！）
## 在GDScript中，整数除法会截断小数部分，这可能导致不期望的结果。
## 在需要精确计算的场景中，必须将操作数转换为浮点数。

## 错误示范：
var ratio = width / height        # 整数除法，会截断小数部分
var center = x + width / 2        # 中心点计算可能不准确
var average = total / count        # 平均值计算会丢失精度

## 正确示范：
var ratio = float(width) / float(height)      # 显式转换为浮点数
var center = x + int(width / 2.0)              # 计算中心点时使用浮点除法
var average = total / float(count)             # 统计计算时保持精度

## 常见需要使用浮点除法的场景：
## 1. 比例计算：房间大小比例、宽高比判断
## 2. 中心点计算：确保几何中心定位准确
## 3. 统计信息：平均值、覆盖率、比率等
## 4. 几何运算：距离、角度、面积计算

## 实际应用示例：
## BSP分割方向判断
if float(node.width) / float(node.height) > config.split_ratio:
    split_direction = "vertical"
elif float(node.height) / float(node.width) > config.split_ratio:
    split_direction = "horizontal"

## 房间比例计算
var width_ratio = float(room_width) / float(leaf.width)
var height_ratio = float(room_height) / float(leaf.height)

## 统计信息计算
var coverage_ratio = used_cells / float(total_cells)
var avg_room_size = total_area / float(room_sizes.size())
var avg_length = total_length / float(connections.size())
    
    ## 实际应用示例：包装地牢数据
    class DungeonWrapper:
        var _grid: Array[Array[int]]  # 私有，不直接暴露
        var _width: int
        var _height: int
        
        func _init(width: int, height: int):
            _width = width
            _height = height
            _initialize_grid()
        
        func _initialize_grid() -> void:
            _grid = []
            for y in range(_height):
                var row: Array[int] = []
                for x in range(_width):
                    row.append(0)
                _grid.append(row)
        
        ## 安全访问：通过方法而非直接引用
        func get_cell(x: int, y: int) -> int:
            if _is_valid_position(x, y):
                return _grid[y][x]
            return -1
        
        ## 安全修改：通过方法控制访问
        func set_cell(x: int, y: int, value: int) -> bool:
            if _is_valid_position(x, y):
                _grid[y][x] = value
                return true
            return false
        
        ## 返回副本而非引用
        func get_grid_copy() -> Array[Array[int]]:
            var copy: Array[Array[int]] = []
            for row in _grid:
                var row_copy: Array[int] = []
                row_copy.append_array(row)
                copy.append(row_copy)
            return copy
        
        func _is_valid_position(x: int, y: int) -> bool:
            return 0 <= x and x < _width and 0 <= y and y < _height


# 示例：完整的类定义
# ===============================================================

## 地牢生成器类
## 使用BSP树和最小生成树算法生成Roguelike风格地牢
@tool
extends RefCounted
class_name DungeonGenerator

## 地牢元素类型枚举
enum CellType {
    EMPTY = 0,      # 空白区域
    ROOM_FLOOR = 1,  # 房间地面
    WALL = 2,        # 墙壁
    CORRIDOR = 3,    # 走廊
    DOOR = 4,        # 门
}

## 2D坐标点类
class Point:
    var x: int
    var y: int
    
    ## 构造函数
    ## @param p_x: X坐标
    ## @param p_y: Y坐标
    func _init(p_x: int, p_y: int):
        x = p_x
        y = p_y
    
    ## 计算到另一个点的距离
    ## @param other: 目标点
    ## @return: 欧几里得距离
    func distance_to(other: Point) -> float:
        var dx = x - other.x
        var dy = y - other.y
        return sqrt(dx * dx + dy * dy)

# 主生成器变量
var config: Dictionary
var grid: Array[Array[int]]

## 生成完整地牢
## @return: 包含生成结果的字典
func generate() -> Dictionary:
    # 实现细节...
    return {"success": true, "data": grid}

# ===============================================================
# GDScript参考手册结束
# ===============================================================
