extends StaticBody2D

var interacting:bool = false

func _process(delta):
	if interacting:
		modulate.r = 0
		modulate.g = 0
		modulate.b += delta
		modulate.b = fmod(modulate.b, 1)
	else:
		modulate.r = 1
		modulate.g = 1
		modulate.b = 1

func start_interact():
	interacting = true

func stop_interact():
	interacting = false
