extends Node

@export var interaction_distance: float = 10.0
@export var interaction_label: Label
@export var original_collision_layer: int = 1
@export var held_object: RigidBody3D = null
@export_flags_3d_physics var detection_mask: int = 1
@onready var camera: Camera3D = $"../Camera3D"
@onready var interaction_ray: RayCast3D = $"../Camera3D/InteractionRay"
@onready var holder: Marker3D = $"../Camera3D/HoldPoint"


func _ready() -> void:
	interaction_ray.target_position = Vector3(0.0, 0.0, -interaction_distance)
	interaction_ray.collision_mask = detection_mask
	interaction_label.text = ""

func _process(_delta: float) -> void:

	if held_object != null:
		interaction_label.text = "[F] Put Down"
	interaction_ray.force_raycast_update()
	if interaction_ray.is_colliding():
		var target = interaction_ray.get_collider()
		if target is RigidBody3D and target.is_in_group("pickupable"):
			interaction_label.text = target.name + "\n[F] Pick Up"
		else:interaction_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if held_object != null:
			put_down()
		else:
			pick_up()

func pick_up() -> void:
	interaction_ray.force_raycast_update()
	if not interaction_ray.is_colliding():
		return
	var target = interaction_ray.get_collider()
	if not target is RigidBody3D:
		return
	held_object = target
	original_collision_layer = held_object.collision_layer
	held_object.freeze = true
	held_object.position = Vector3.ZERO
	held_object.rotation = Vector3.ZERO
	held_object.linear_velocity = Vector3.ZERO
	held_object.angular_velocity = Vector3.ZERO
	held_object.collision_layer = 0
	held_object.reparent(holder, false)

func put_down() -> void:
	var dropped_object = held_object
	held_object = null
	dropped_object.reparent(get_tree().current_scene, true)
	dropped_object.global_position = (camera.global_position - camera.global_basis.z * 2.0)
	dropped_object.collision_layer = original_collision_layer
	dropped_object.freeze = false
	dropped_object.sleeping = false
