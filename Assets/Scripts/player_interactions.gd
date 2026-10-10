extends Node

@export var interaction_distance: float = 10.0
@export var interaction_label: Label
@onready var interaction_ray: RayCast3D = $"../Camera3D/InteractionRay"
@export_flags_3d_physics var detection_mask: int = 1

func _ready() -> void:
	interaction_ray.target_position = Vector3(0.0, 0.0, -interaction_distance)
	interaction_ray.collision_mask = detection_mask
	interaction_label.text = ""

func _process(_delta: float) -> void:
	interaction_ray.force_raycast_update()
	if interaction_ray.is_colliding():
		var target = interaction_ray.get_collider()
		interaction_label.text = target.name
	else:
		interaction_label.text = ""
	pass
