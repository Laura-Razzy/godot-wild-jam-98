extends CharacterBody3D
# Comments are for myself because I'm still learning GDScript! I know it's too much, please don't judge! :3
@export var move_speed: float = 5
@export var mouse_sensitivity: float = 0.0025
@export var vertical_rotation: float = 0.0
@export var crouching: bool = false
@export var cam_height: Vector3
@onready var cam: Camera3D = $Camera3D

func _ready() -> void: # This is for when a node appears like Start()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Makes the mouse invisible
	cam_height = cam.position

func _process(delta: float) -> void: # Polls every frame like Update(), Time.deltaTime is just delta.
	if not is_on_floor():
		velocity += get_gravity() * delta
	check_crouch()
	cam.position = cam.position.lerp(cam_height, 8 * delta)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	move_and_slide() # After all the math, this is just a move function!

func _unhandled_input(event: InputEvent) -> void: # This makes it so you don't have to poll every frame for mouse inputs since godot handles that directly!
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		vertical_rotation -= event.relative.y * mouse_sensitivity
		vertical_rotation = clampf(vertical_rotation, deg_to_rad(-90.0), deg_to_rad(90.0))
	cam.rotation.x = vertical_rotation
	if event.is_action_pressed("ui_cancel"): # This makes it so the mouse shows when you bring up a UI
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 

func check_crouch():
	crouching = Input.is_action_pressed("crouch")
	if crouching:
		move_speed = 3
		cam_height.y = 0.6
	else:
		move_speed = 5
		cam_height = Vector3(cam.position.x, 1.6, cam.position.z)
