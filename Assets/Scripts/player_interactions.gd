extends Node
# Comments are for myself because I'm still learning GDScript! I know it's too much, please don't judge! :3
@export var interaction_distance: float = 10.0
@export var original_collision_layer: int = 1
@export var held_object: RigidBody3D = null
@export var player_ui: PlayerUI
@export_flags_3d_physics var detection_mask: int = 1
@onready var camera: Camera3D = $"../Camera3D"
@onready var interaction_ray: RayCast3D = $"../Camera3D/InteractionRay" # InteractionRay is just a RayCast
@onready var holder: Marker3D = $"../Camera3D/HoldPoint"

func _ready() -> void:
	interaction_ray.target_position = Vector3(0.0, 0.0, -interaction_distance) # Z is backwards on godot...
	interaction_ray.collision_mask = detection_mask

func _process(_delta: float) -> void: #If it's holding something, it says put down, if it's not and you point towards it, it says pick up.
	if held_object != null:
		player_ui.show_interaction_text("[F] Put Down")
		return
	interaction_ray.force_raycast_update()
	if interaction_ray.is_colliding():
		var target = interaction_ray.get_collider()
		if target is RigidBody3D:
			if target.is_in_group("pickupable"):
				player_ui.show_interaction_text(target.name + "\n[F] Pick Up")
			if target.is_in_group("interactable"):
				player_ui.show_interaction_text(target.name + "\n[F] Interact")
		else:
			player_ui.show_interaction_text("")
	else:
		player_ui.show_interaction_text("")

func _unhandled_input(event: InputEvent) -> void: #If you ask to interact, it tries to interact!
	if event.is_action_pressed("interact"):
		if held_object != null:
			put_down()
		else:
			pick_up()

func pick_up() -> void:
	interaction_ray.force_raycast_update() # Draws the raycast
	if not interaction_ray.is_colliding():
		return
	var target = interaction_ray.get_collider()
	if not target is RigidBody3D:
		return
	# This part is genuinely so disgusting there has to be a better way to do this.
	held_object = target # In this kind of language it's apparently optimal to declare a new variable inside of a function so it doesn't have to call from outside.
	original_collision_layer = held_object.collision_layer # This is so we can call it back later in the drop function.
	held_object.freeze = true # Freeze pauses the node's physics
	held_object.position = Vector3.ZERO
	held_object.rotation = Vector3.ZERO
	held_object.linear_velocity = Vector3.ZERO
	held_object.angular_velocity = Vector3.ZERO
	held_object.collision_layer = 0 # This changes the object's type so it doesn't accidentally mess up raycast things while holding it.
	held_object.reparent(holder, false) # This puts the the holder as the parent

func put_down() -> void: # I hate this!
	var dropped_object = held_object
	held_object = null
	dropped_object.reparent(get_tree().current_scene, true) # This puts it back in the ground
	dropped_object.global_position = (camera.global_position - camera.global_basis.z * 2.0)
	dropped_object.collision_layer = original_collision_layer # Gives the old layer back to the item.
	dropped_object.freeze = false
	dropped_object.sleeping = false
