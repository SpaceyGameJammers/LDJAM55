extends State
class_name InteractState

@export var character: Entity

var move_direction:Vector2
var wander_time:float
var timer:Timer
var workstation:Workstation
var type
var target: Vector2

func enter(_msg := {}):
	workstation = _msg["station"]
	type = _msg["type"]
	target = _msg["target"]
	character.position = target
	if workstation:
		if character.occupation == character.OCCUPATION.CUSTOMER:
			if !workstation.customer_work_done.is_connected(_on_customer_timeout):
				workstation.customer_work_done.connect(_on_customer_timeout)
		else:
			if !workstation.work_done.is_connected(_on_work_timeout):
				workstation.work_done.connect(_on_work_timeout)
		if character.occupation == character.OCCUPATION.CUSTOMER:
			workstation.customer_interact(character)
		else:
			workstation.start_worker_interact()
	else:
		state_machine.transition_to("TargetState", {})
	if type == character.INTERACTION.WAIT:
		character.wait_timer.timeout.connect(_on_wait_over)
		character.wait_timer.start()

func physics_update(_delta:float):
	if character.occupation == character.OCCUPATION.CUSTOMER:
		character.human_renderer.update_direction((workstation.global_position - workstation.get_customer_position()).normalized())
	else:
		character.human_renderer.update_direction((workstation.global_position - workstation.get_worker_position()).normalized())
	character.human_renderer.update_direction(Vector2.ZERO)
	if type == character.INTERACTION.WAIT:
		character.human_renderer.sit((workstation.global_position - workstation.get_customer_position()).normalized())

func _on_wait_over():
	print("_____________________")
	if character.occupation == character.OCCUPATION.CUSTOMER:
		print(str(workstation) + ": MAD LEAVING")
		state_machine.transition_to("TargetState", {"state": "mad"})
	else:
		print(str(workstation) + ": WORK CANCELED")
		workstation.work_done.emit()
		state_machine.transition_to("TargetState", {})
	print("_____________________")

func _on_customer_timeout():
	print(str(workstation) + ": CUSTOMER DONE")
	WorkstationManager.release_customer_workstation(workstation.type, workstation)
	state_machine.transition_to("TargetState", {})

func _on_work_timeout():
	print(str(workstation) + ": WORK DONE")
	WorkstationManager.release_workstation(workstation.type, workstation)
	state_machine.transition_to("TargetState", {})
