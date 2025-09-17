extends Camera3D

func _ready():
	if is_multiplayer_authority():
		make_current()
