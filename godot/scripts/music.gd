extends AudioStreamPlayer

func _ready():
	MusicManager.register_audio_player(self)
