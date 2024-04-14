extends State
class_name IdleState

@export var station: WorkstationPot

func enter(_msg := {}):
	station.sprite.frame = 1
	station.progress_bar.visible = false
	station.food_icon.visible = false

func physics_update(_delta:float):
	if station.progress_bar.value > 9.0:
		state_machine.transition_to("CookingState", {})
	if !station.has_pot:
		state_machine.transition_to("EmptyState", {})

func exit():
	pass
