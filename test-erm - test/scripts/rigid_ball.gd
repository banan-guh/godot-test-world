extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	continuous_cd = true

func _physics_process(_delta: float) -> void:
	if global_position.y < -10:
		global_position = get_node("../spawnPoint").global_position
