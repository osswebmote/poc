extends Node2D

var peer = ENetMultiplayerPeer.new()
var is_host = false
var is_client = false
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	#multiplayer.connect("peer_connected", Callable(self, "_on_peer_connected"))


# 클라이언트로부터 메시지 수신
func _process(delta):
	time += 1
	if multiplayer.multiplayer_peer:
		if is_host:
			# 호스트(서버)로서 클라이언트로부터 데이터 수신
			if time % 60 == 1:
				pass
				#print("패킷개수:", multiplayer.multiplayer_peer.get_available_packet_count())
				#var packet = multiplayer.multiplayer_peer.get_packet()
				#print("패킷내용: ", packet)
				#var message = packet.get_string_from_utf8()
				#print("클라이언트로부터 받은 메시지: ", message)
				
			#while multiplayer.multiplayer_peer.get_available_packet_count() > 0:
				#var packet = multiplayer.multiplayer_peer.get_packet()
				#var message = packet.get_string_from_utf8()
				#print("클라이언트로부터 받은 메시지: ", message)
		if is_client:
			# 클라이언트로서 서버에 데이터 전송 (여기서는 자이로스코프 데이터 예시)
			if time % 60 == 1:
				_send_packet()
				#var gyro_data = Input.get_gyroscope()  # 자이로스코프 데이터 가져오기
				#var message = {
					#"gyro_x": gyro_data.x,
					#"gyro_y": gyro_data.y,
					#"gyro_z": gyro_data.z
				#}
				#var message = "hello_man"
#
				## UTF-8 바이트 배열로 변환
				#var packet = message.to_utf8_buffer()

				#var result = multiplayer.multiplayer_peer.put_packet(packet)
				#if result == OK:
					#print("패킷이 성공적으로 전송되었습니다: ", message)
				#else:
					#print("패킷 전송 실패")
					#print("서버로 자이로스코프 데이터 전송: ", message)
			

# 연결되었을 때 호출되는 함수
func _on_peer_connected(id):
	print("피어가 연결되었습니다! ID: ", id)
	# 클라이언트로서 서버에 데이터 전송 (여기서는 자이로스코프 데이터 예시)

func _on_host_pressed() -> void:
	# 서버 시작 (포트: 2450, 최대 클라이언트: 10명)
	peer.create_server(2450, 10)
	multiplayer.multiplayer_peer = peer
	is_host = true
	print("서버가 시작되었습니다!")

func _on_client_pressed() -> void:
	# 서버에 연결 (IP 주소: 로컬호스트, 포트: 2450)
	peer.create_client("127.0.0.1", 2450)
	multiplayer.multiplayer_peer = peer
	is_client = true
	print("서버에 연결되었습니다!")

# RPC로 호출될 함수 (패킷이 수신될 때 자동으로 호출됨)
@rpc("any_peer")
func msg_rpc(message):
	print("메세지 도착했습니다: ", message)

# 패킷을 보내는 클라이언트가
func _send_packet():
	var gyro_data = Input.get_gyroscope()  # 자이로스코프 데이터 가져오기
	var message = {
		"gyro_x": gyro_data.x,
		"gyro_y": gyro_data.y,
		"gyro_z": gyro_data.z
	}
	rpc("msg_rpc", message)  # RPC 호출을 통해 서버로 메시지 전송
	
