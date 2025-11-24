extends SubViewportContainer

@export var color_rect:TextureRect
@onready var sub_viewport: SubViewport = $SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	color_rect.global_position = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("escape"):
		sub_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	if Input.is_action_just_pressed("fire"):
		color_rect.reparent(get_child(0))
	elif Input.is_action_just_released("fire"):
		color_rect.reparent(self)
