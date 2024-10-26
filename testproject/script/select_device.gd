extends Node2D

var is_mobile;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_mobile = JavaScriptBridge.eval("""/Mobi/i.test(window.navigator.userAgent);""")

func _process(delta: float) -> void:

# Called every frame. 'delta' is the elapsed time since the previous frame.
	pass

func _on_button_pressed() -> void:
	if not is_mobile:
		global_data.do_computer_link()
		get_tree().change_scene_to_file("res://scene/computer_room.tscn")
	else:
		JavaScriptBridge.eval("alert('you are not a computer')")

func _on_button_2_pressed() -> void:
	if is_mobile:
		global_data.do_smartphone_link()
		get_tree().change_scene_to_file("res://scene/smartphone_pad.tscn")
	else:
		JavaScriptBridge.eval("alert('you are not a phone')")
	
