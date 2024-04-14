extends State
class_name InteractState

@export var character: CharacterBody2D
@export var move_speed:float = 10.0

var move_direction:Vector2
var wander_time:float
var timer:Timer
var workstation:Workstation

func enter(_msg := {}):
	workstation = _msg["station"]
	if workstation:
		workstation.start_worker_interact()
		workstation.work_done.connect(_on_timer_timeout)
	else:
		state_machine.transition_to("TargetState", {})

func _on_timer_timeout():
	state_machine.transition_to("TargetState", {})

func exit():
	if workstation:
		workstation.stop_worker_interact()
