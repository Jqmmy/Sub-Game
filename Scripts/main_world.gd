extends Node3D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2
@onready var submarine: RigidBody3D = %Submarine
@onready var world_environment: WorldEnvironment = $WorldEnvironment

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player_2.play()

func _physics_process(delta: float) -> void:
	if submarine.global_position.y < -10:
		world_environment.environment.volumetric_fog_albedo = Color(0.0, 0.424, 0.737)

func _on_ocean_player_jumped_in_water() -> void:
	audio_stream_player.play()
	audio_stream_player_2.stop()
