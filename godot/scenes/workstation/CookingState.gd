extends State
class_name CookingState

@export var station: WorkstationPot

func enter(_msg := {}):
	station.sprite.frame = 2
	station.progress_bar.visible = true

func physics_update(_delta:float):
	station.food_icon.visible = station.progress_bar.value == station.progress_bar.max_value
	if !station.has_pot:
		state_machine.transition_to("EmptyState", {})
	elif station.progress_bar.value == 0.0:
		state_machine.transition_to("IdleState", {})

func exit():
	pass
