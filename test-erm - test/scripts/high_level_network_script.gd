extends Node

const IP_ADDRESS: String = "localhost"
const PORT: int = 1001
var is_multiplayer: bool = false

var peer: ENetMultiplayerPeer

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	get_window().title = "Multiplayer Server"

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	is_multiplayer = true
