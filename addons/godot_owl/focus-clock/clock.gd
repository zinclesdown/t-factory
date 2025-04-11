@tool
extends MarginContainer

# note: this matches the item order in ClockDisplayer.
enum DateFormatType { 
	LONG_DATE,
	SHORT_DATE
}

var date_type :DateFormatType = DateFormatType.LONG_DATE


func _process(delta: float) -> void:
	var time_dict :Dictionary = Time.get_datetime_dict_from_system()
	# year month day weekday hour minute second dst
	var year :int= time_dict["year"]
	var month:int= time_dict["month"]
	var day:int= time_dict["day"]
	var weekday:int= time_dict["weekday"]
	var hour:int= time_dict["hour"]
	var minute:int= time_dict["minute"]
	var second:int= time_dict["second"]
	var dst:bool= time_dict["dst"]
	
	var text :String=""
	
	match date_type:
		DateFormatType.LONG_DATE:
			%ClockDisplayer.text = " %4d年%d月%d日星期%s  %2d:%2d:%2d " % [year, month, day, capitalize_weekday_zh_cn(weekday), hour, minute, second]
		DateFormatType.SHORT_DATE:
			%ClockDisplayer.text = " %4d/%d/%d  %2d:%2d:%2d " % [year, month, day, hour, minute, second]


func _on_clock_displayer_pressed() -> void:
	var menu := %ClockDisplayer.get_popup() as PopupMenu
	for connection:Dictionary in menu.id_pressed.get_connections():
		(connection["signal"] as Signal).disconnect(connection["callable"])
	menu.id_pressed.connect(
		func(id:int):
			date_type = id
			print("you changed the display type.")
	)



func capitalize_weekday_zh_cn(num:int)->String:
	match num:
		1:
			return "一"
		2:
			return "二"
		3:
			return "三"
		4:
			return "四"
		5:
			return "五"
		6:
			return "六"
		7:
			return "日"
		_:
			return "ERROR"


func _on_full_screen_toggle_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		EditorInterface.get_editor_main_screen().get_viewport().mode = Window.MODE_FULLSCREEN
	else:
		EditorInterface.get_editor_main_screen().get_viewport().mode = Window.MODE_WINDOWED
