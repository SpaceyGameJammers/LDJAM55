extends Node

var main_song: AudioStream = load("res://audio/song1.wav")
var main_song_position = 0
var audio_player: AudioStreamPlayer = null

func register_audio_player(new_audio_player:AudioStreamPlayer):
	new_audio_player.finished.connect(reset_music)
	audio_player = new_audio_player
	audio_player.set_stream(main_song)
	audio_player.play(main_song_position)
	

func change_music(song:AudioStream):
	if audio_player != null:
		main_song_position = audio_player.get_playback_position()
		audio_player.set_stream(song)
		audio_player.play(0)
	
func reset_music():
	if audio_player != null:
		audio_player.set_stream(main_song)
		audio_player.play(main_song_position)
