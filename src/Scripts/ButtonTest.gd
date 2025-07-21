class_name ButtonTest extends Node

var server: UDPServer


func buttonPressed():
	## Override with your own functionality
	print("Button press detected")


func _ready() -> void:
	# Set up the server and start listening for inputs
	server = UDPServer.new()
	server.listen(4242)


func _process(delta: float) -> void:
	# Every frame, check if we've got any incoming data
	server.poll()
	if not server.is_connection_available():
		return
	
	buttonPressed()
	
	# Make sure we respond to the Python script so things don't freeze up
	var peer: PacketPeerUDP = server.take_connection()
	var packet := peer.get_packet()
	print("Received: '%s' %s:%s" % [packet.get_string_from_utf8(), peer.get_packet_ip(), peer.get_packet_port()])
	peer.put_packet("Button input received from Godot".to_utf8_buffer())
