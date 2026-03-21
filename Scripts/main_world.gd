extends Node3D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player_2.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ocean_player_jumped_in_water() -> void:
	audio_stream_player.play()
	audio_stream_player_2.stop()


func _on_gem_picked_up() -> void:
	const TEMP_ENDING_SCREEN = preload("uid://dp1yow8xlbn1l")
	var timer = get_tree().create_timer(8.0).timeout.connect(
		func():
			get_tree().change_scene_to_packed(TEMP_ENDING_SCREEN))
