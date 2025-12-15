class_name Interactable
extends Area3D

var hovering:bool = false:
	set = set_hovering
@export_multiline var hover_text:String

signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(func(body):
		if body.is_in_group("player"):
			interacted.emit()
			)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if hovering:
		if Input.is_action_just_pressed("interact"):
			interacted.emit()
		

func set_hovering(value:bool):
	hovering = value
	var hud = get_tree().get_first_node_in_group("hud") as Hud
	if hovering == true:
		hud.add_hover_text(hover_text, InputMap.get_action_description("interact"))
	else:
		hud.add_hover_text("")
