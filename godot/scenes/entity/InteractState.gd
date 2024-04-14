extends State
class_name InteractState

@export var character: Entity

var move_direction:Vector2
var wander_time:float
var timer:Timer
var workstation:Workstation
var type

func enter(_msg := {}):
	workstation = _msg["station"]
	type = _msg["type"]
	if workstation:
		workstation.work_done.connect(_on_timer_timeout)
		if character.occupation == character.OCCUPATION.CUSTOMER and workstation.has_method("customer_interact"):
			workstation.customer_interact(character)
		else:
			workstation.start_worker_interact()
	else:
		state_machine.transition_to("TargetState", {})
	
	if type == character.INTERACTION.WAIT:
		character.wait_timer.timeout.connect(_on_wait_over)
		character.wait_timer.start()

func _on_wait_over():
	state_machine.transition_to("TargetState", {"state": "mad"})

func _on_timer_timeout():
	state_machine.transition_to("TargetState", {})

func exit():
	if workstation and character.occupation != character.OCCUPATION.CUSTOMER:
		WorkstationManager.release_workstation(workstation.type, workstation)
	if workstation and character.occupation == character.OCCUPATION.CUSTOMER:
		WorkstationManager.release_customer_workstation(workstation.type, workstation)
