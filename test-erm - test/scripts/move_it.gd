extends CharacterBody3D


const accel = 50.0
const deaccel = 150.0
var speed
const base_speed = 8.0
const sprint_addded_speed = 8.0
const JUMP_VELOCITY = 10
const camera_speed = 0.005
const push_force = 1.0
var field_of_view = 90

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity: float = 35

@onready var body := get_node(".")
@onready var bodySkin := get_node("MeshInstance3D")
@onready var camera := get_node("Camera3D")
@onready var head := get_node("Camera3D/MeshInstance3D")
@onready var startRotation = global_rotation

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	print("hello world!  my name is ", name)
	print("you can find my node here: ", self.get_path())
	get_window().title = "Test world! " + name

func select_object() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif Input.is_action_pressed("GETOUT"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			camera.rotate_x(-event.relative.y * camera_speed)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			if multiplayer_bool():
				body.rotate_y(-event.relative.x * camera_speed)
				head.rotate_x(-event.relative.y * camera_speed)


func _respawn_check() -> void:
	if global_position.y < -10 or Input.is_action_just_pressed("respawn"):
		_respawn()
	
func _respawn() -> void:
	var spawn = get_node("/root/world/spawnPoint")
	self.global_position = spawn.global_position
	self.global_rotation = startRotation
	camera.global_rotation = startRotation
	velocity = Vector3(0, 0, 0)


func multiplayer_bool() -> bool:
	if self.get_multiplayer_authority() == multiplayer.get_unique_id():
		return true
	else: return false


func _physics_process(delta: float) -> void:
	#Check if the player is the player. idk it made sense in my head
	if self.get_multiplayer_authority() == multiplayer.get_unique_id():
		pass
	
	# Check if player has fallen into the void / pressed respawn.
	_respawn_check()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle Sprint.
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("forward"):
		speed = base_speed + sprint_addded_speed
		camera.set_fov(move_toward(camera.fov, field_of_view + 5, 0.8))
	else:
		speed = base_speed
		camera.set_fov(move_toward(camera.fov, field_of_view, 0.8))

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * speed, delta * accel * abs(direction.x))
		velocity.z = move_toward(velocity.z, direction.z * speed, delta * accel * abs(direction.z))
		#print("x dir: ", direction.x)
		#print("z dir: ", direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0, deaccel * delta * abs(velocity.x))
		velocity.z = move_toward(velocity.z, 0, deaccel * delta * abs(velocity.z))
	
	# Handle collisions for pushing RigidBodies
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody3D:
			print(collision)
			var rigid_body = collision.get_collider()
			# Apply impulse in the direction opposite to the collision normal
			rigid_body.apply_impulse(-collision.get_normal() * push_force)

	move_and_slide()
