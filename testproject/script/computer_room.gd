extends Node2D

var remote_position
var speed = 5.0

var gyro_x 
var gyro_y 
var gyro_z 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var view_center = get_viewport().get_size() / 2  # 정중앙 좌표 계산 (가로/2, 세로/2)
	remote_position = view_center
	$remote_mouse.position = remote_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_data.both_connect_true:
		$connect.text = "linked"
		$connect.set("theme_override_colors/font_color",Color(0, 1, 0, 1))
	
	if global_data.gyro_com_x >= 0 and global_data.gyro_com_x <= 90:
		gyro_x = -global_data.gyro_com_x
	elif global_data.gyro_com_x >= 270 and global_data.gyro_com_x <= 360:
		gyro_x = 360 - global_data.gyro_com_x + 30
	else:
		gyro_x = 0
		
	if global_data.gyro_com_y >= 90 and global_data.gyro_com_y <= -90:
		gyro_y = 0
	elif global_data.gyro_com_y <= 0 and global_data.gyro_com_y >= -90:
		gyro_y = -global_data.gyro_com_y + 30
	else:
		gyro_y = -global_data.gyro_com_y
		
	var move_x = gyro_x * speed * delta 
	var move_y = gyro_y * speed * delta
	
	remote_position.x = clamp(remote_position.x + move_x, 0, get_viewport().size.x)
	remote_position.y = clamp(remote_position.y + move_y, 0, get_viewport().size.y)
	
	$remote_mouse.position = remote_position
	
		

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/selectDevice.tscn")


## 특정 위치와 속성으로 마우스 클릭 이벤트 발생
#func _simulate_mouse_click(x: int, y: int, button_index: int, pressed: bool):
	#var mouse_event = InputEventMouseButton.new()
	#mouse_event.button_index = button_index  # 1: 왼쪽 클릭, 2: 오른쪽 클릭, 3: 휠 클릭 등
	#mouse_event.position = Vector2(x, y)     # 클릭할 좌표 설정
	#mouse_event.pressed = pressed            # true면 눌림, false면 뗌
	#mouse_event.global_position = Vector2(x, y)  # 전역 좌표 설정 (필요한 경우)
	#
	## 이벤트 발생
	#get_tree().input_event(mouse_event)
#
## 예를 들어, 왼쪽 클릭을 특정 좌표에서 강제 발생시킴
#func _ready():
	#_simulate_mouse_click(200, 150, BUTTON_LEFT, true)  # 왼쪽 클릭 눌림
	#_simulate_mouse_click(200, 150, BUTTON_LEFT, false) # 왼쪽 클릭 뗌
