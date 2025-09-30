class_name Interactable
extends Area3D

var hovering:bool = false

signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	body_entered.connect(func(body):
		print(body)
		if body.is_in_group("player"):
			interacted.emit()
			print("kdifgb"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hovering:
		if Input.is_action_just_pressed("interact"):
			interacted.emit()

func on_mouse_entered():
	hovering = true

func on_mouse_exited():
	hovering = false
