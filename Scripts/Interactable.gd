class_name Interactable
extends Area3D

var hovering:bool = false:
	set = set_hovering
##text displayed when hovering object
@export_multiline var hover_text:String
@export var holdable:bool = false
@export var enabled:bool = true:
	set(value):
		enabled = value
		if not enabled:
			var hud = get_tree().get_first_node_in_group("hud") as Hud
			hud.add_hover_text("")

signal interacted

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if hovering and enabled:
		if Input.is_action_just_pressed("interact"):
			interacted.emit()
		if holdable and Input.is_action_pressed("interact"):
			interacted.emit()

func set_hovering(value:bool):
	hovering = value
	if enabled:
		var hud = get_tree().get_first_node_in_group("hud") as Hud
		if hovering == true:
			hud.add_hover_text(hover_text, InputMap.get_action_description("interact"))
		else:
			hud.add_hover_text("")
