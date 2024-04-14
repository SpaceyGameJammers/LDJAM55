extends State
class_name InteractState

@export var character: Entity

var move_direction:Vector2
var wander_time:float
var timer:Timer
var workstation:Workstation

func enter(_msg := {}):
	workstation = _msg["station"]
	if workstation:
		workstation.work_done.connect(_on_timer_timeout)
		if workstation.has_method("customer_interact"):
			workstation.customer_interact(character)
		else:
			workstation.start_worker_interact()
	else:
		state_machine.transition_to("TargetState", {})

func _on_timer_timeout():
	state_machine.transition_to("TargetState", {})

func exit():
	if workstation and !workstation.has_method("customer_interact"):
		workstation.stop_worker_interact()
