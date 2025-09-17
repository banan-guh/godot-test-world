extends Control

var isPaused = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event):
	if event.is_action_pressed("esc"):
		doPause()

func doPause():
	if isPaused:
		resume()
	else:
		pause()
	isPaused = !isPaused

func pause():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	if HighLevelNetworkScript.is_multiplayer:
		return
	else:
		get_tree().paused = true

func resume():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	
func quit():
	get_tree().quit()


func _on_resume_pressed() -> void:
	doPause()


func _on_quit_pressed() -> void:
	quit()
