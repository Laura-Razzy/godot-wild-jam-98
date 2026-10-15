extends CanvasLayer
# Comments are for myself because I'm still learning GDScript! I know it's too much, please don't judge! :3
class_name PlayerUI
@export var interaction_text: Label
@export var dialogue_text: Label

func _ready() -> void:
	interaction_text.hide()
	dialogue_text.hide()


func show_interaction_text(interaction_message: String) -> void:
	interaction_text.text = interaction_message
	interaction_text.visible = not interaction_message.is_empty()

func show_dialogue_text(dialogue_message: String) -> void:
	dialogue_text.text = dialogue_message
	dialogue_text.show()

func hide_dialogue_text() -> void:
	dialogue_text.hide()
