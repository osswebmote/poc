extends Node

# The URL we will connect to.
@export var websocket_url = "wss://port-0-godot-test-server-azyqdr152alrrlmezx.sel5.cloudtype.app/"

# Our WebSocketPeer instance.
var socket 

# Variable to keep track of time for 60 seconds intervals
var time = 0

var _callback_accel
var _callback_orientation

var _callback_com_accel
var _callback_com_orientation
var _callback_connect
var window

var accel_x = 0.0
var accel_y = 0.0
var accel_z = 0.0
var gyro_x = 0.0
var gyro_y = 0.0
var gyro_z = 0.0

var accel_com_x = 0.0
var accel_com_y = 0.0
var accel_com_z = 0.0
var gyro_com_x = 0.0
var gyro_com_y = 0.0
var gyro_com_z = 0.0

var mobile = false
var computer = false

var both_connect_true = false

var once_type_message = true

func _ready():
	set_process(false)


# 가속도 데이터를 받는 함수
func on_receive_data(data):
	accel_x  = JavaScriptBridge.eval("""window.accelerometer_data_x""")
	accel_y  = JavaScriptBridge.eval("""window.accelerometer_data_y""")
	accel_z  = JavaScriptBridge.eval("""window.accelerometer_data_z""")

# 방향 데이터를 받는 함수
func on_receive_orientation(data):
	gyro_x = JavaScriptBridge.eval("""window.orientation_data_x""")
	gyro_y = JavaScriptBridge.eval("""window.orientation_data_y""")
	gyro_z = JavaScriptBridge.eval("""window.orientation_data_z""")

func on_receive_com_data(data):
	accel_com_x  = JavaScriptBridge.eval("""window.accelerometer_com_data_x""")
	accel_com_y  = JavaScriptBridge.eval("""window.accelerometer_com_data_y""")
	accel_com_z  = JavaScriptBridge.eval("""window.accelerometer_com_data_z""")

func on_receive_com_orientation(data):
	gyro_com_x = JavaScriptBridge.eval("""window.orientation_com_data_x""")
	gyro_com_y = JavaScriptBridge.eval("""window.orientation_com_data_y""")
	gyro_com_z = JavaScriptBridge.eval("""window.orientation_com_data_z""")
	
func on_receive_connect_data(data):
	both_connect_true = true
	print("실행됐음")
	
func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()
	
	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if once_type_message:
			var client_type = {
				"event": "type_phone",
				"fake_data": "fake"
			}
			var client_string = JSON.stringify(client_type)
			socket.send_text(client_string)  # 연결 후에 데이터를 전송
			once_type_message = false

	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		set_process(false) # Stop processing.
	
	if mobile:
		var gyro_json = {
			"event": "gyroscope_data",
			"x": gyro_x,
			"y": gyro_y,
			"z": gyro_z
		}
		
		# JSON 데이터를 문자열로 변환
		var json_string2 = JSON.stringify(gyro_json)
		socket.send_text(json_string2)

	
	if computer:
		pass
		
# 컴퓨터로 참여하기 버튼 
func do_computer_link() -> void:
	print("godot print 콘솔에 나옴")
	computer = true
	_callback_com_accel = JavaScriptBridge.create_callback(on_receive_com_data)
	_callback_com_orientation = JavaScriptBridge.create_callback(on_receive_com_orientation)
	_callback_connect = JavaScriptBridge.create_callback(on_receive_connect_data)
	# window 객체에서 JavaScript와 연결
	window = JavaScriptBridge.get_interface("window")

	# JavaScript 측에서 호출할 수 있도록 콜백 등록
	window.onGodotComAccelData = _callback_com_accel
	window.onGodotComOrientationData = _callback_com_orientation
	window.onGodotConnect = _callback_connect
	
	var js_code1 = """
		// WebSocket 서버에 연결
		const socket = new WebSocket('wss://port-0-godot-test-server-azyqdr152alrrlmezx.sel5.cloudtype.app/');
		
		// WebSocket 연결이 열렸을 때 실행되는 이벤트 핸들러
		socket.onopen = function(event) {
			console.log("연결되긴 했음.")
			if (socket.readyState === WebSocket.OPEN) {
				socket.send(JSON.stringify({ "event": "type_computer" }));
			} else {
				console.log("WebSocket is not open yet. Current state: ", socket.readyState);
			}
		};

		socket.onmessage = function(event) {
			let parsedData = JSON.parse(event.data);
			if (parsedData.event == "gyroscope_data") {
				window.orientation_com_data_x = parsedData.x;
				window.orientation_com_data_y = parsedData.y;
				window.orientation_com_data_z = parsedData.z;
				window.onGodotComOrientationData();
			}
			if (parsedData.event == "alertconnect") {
				window.onGodotConnect();
			}
		};
	"""
	JavaScriptBridge.eval(js_code1)

	set_process(true)
	
# 스마트폰으로 참여하기 버튼
func do_smartphone_link() -> void:
	socket = WebSocketPeer.new()
	mobile = true
	# 콜백을 등록하여 JavaScript에서 데이터를 받을 수 있도록 준비합니다.
	_callback_accel = JavaScriptBridge.create_callback(on_receive_data) #얘가 동작하려면 콜백함수가 하나의 매개변수를 가지도록 해야함; 매개변수가 다르면 다른함수취급함 ㅅ
	_callback_orientation = JavaScriptBridge.create_callback(on_receive_orientation)
	# window 객체에서 JavaScript와 연결
	window = JavaScriptBridge.get_interface("window")

	# JavaScript 측에서 호출할 수 있도록 콜백 등록
	window.onGodotAccelData = _callback_accel
	window.onGodotOrientationData = _callback_orientation
	
	var js_code1 = """
			window.addEventListener('devicemotion', function(event) {
				var acceleration = event.accelerationIncludingGravity;
				window.accelerometer_data_x = acceleration.x;
				window.accelerometer_data_y = acceleration.y;
				window.accelerometer_data_z = acceleration.z;
				window.onGodotAccelData();
			});
		"""
	JavaScriptBridge.eval(js_code1)
	
	var js_code2 = """
	if (typeof DeviceMotionEvent !== 'undefined' && typeof DeviceMotionEvent.requestPermission === 'function') {
		DeviceMotionEvent.requestPermission().then(permissionState => {
			if (permissionState === 'granted') {
				window.addEventListener('deviceorientation', function(event) {
					window.orientation_data_x = event.alpha;
					window.orientation_data_y = event.beta;
					window.orientation_data_z = event.gamma;
					window.onGodotOrientationData();
				});
			} else {
				alert("권한을 허용하지 않으셔서 자이로스코프 데이터를 사용 할 수 없습니다.")
			}
		})
	} else {
		window.addEventListener('deviceorientation', function(event) {
			window.orientation_data_x = event.alpha;
			window.orientation_data_y = event.beta;
			window.orientation_data_z = event.gamma;
			window.onGodotOrientationData();
		});
	}
	"""
	JavaScriptBridge.eval(js_code2)
	
	socket.connect_to_url(websocket_url)
	
	set_process(true)
	
func close_connect() -> void:
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.close()
