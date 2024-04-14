extends State
class_name EmptyState

@export var station: WorkstationPot

func enter(_msg := {}):
	station.sprite.frame = 0
	station.progress_bar.visible = false
	station.food_icon.visible = false

func physics_update(_delta:float):
	if station.has_pot:
		state_machine.transition_to("IdleState", {})

func exit():
	pass
