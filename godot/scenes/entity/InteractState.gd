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

func update(_delta):
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
		if not character.wait_timer.timeout.is_connected(_on_wait_over):
			character.wait_timer.timeout.connect(_on_wait_over)
		character.wait_timer.start()
	if !character.occupation_changed.is_connected(_set_oc):
		character.occupation_changed.connect(_set_oc)

func physics_update(_delta:float):
	if character.occupation == character.OCCUPATION.CUSTOMER:
		character.human_renderer.update_direction((workstation.global_position - workstation.get_customer_position()).normalized())
	else:
		character.human_renderer.update_direction((workstation.global_position - workstation.get_worker_position()).normalized())
	character.human_renderer.update_direction(Vector2.ZERO)
	if type == character.INTERACTION.TABLE:
		if workstation.current_customer == null:
			state_machine.transition_to("TargetState", {})
	if type == character.INTERACTION.WAIT:
		character.human_renderer.sit((workstation.global_position - workstation.get_customer_position()).normalized())

func _on_wait_over():
	if character.occupation == character.OCCUPATION.CUSTOMER:
		print(str(workstation) + ": MAD LEAVING")
		if type == character.INTERACTION.LEAVE:
			ResourceManager.change_rating(randf_range(0.0, 0.2))
		state_machine.transition_to("TargetState", {"state": "mad"})
	else:
		print(str(workstation) + ": WORK CANCELED")
		workstation.work_done.emit()
		state_machine.transition_to("TargetState", {})

func _on_customer_timeout():
	print(str(workstation) + ": CUSTOMER DONE " + str(type))
	if type == character.INTERACTION.WAIT:
		character.wait_timer.paused = true 
		ResourceManager.change_rating(character.wait_timer.time_left/(character.wait_timer.wait_time-workstation.timer.wait_time))
	WorkstationManager.release_customer_workstation(workstation.type, workstation)
	state_machine.transition_to("TargetState", {})

func _on_work_timeout():
	print(str(workstation) + ": WORK DONE")
	WorkstationManager.release_workstation(workstation.type, workstation)
	state_machine.transition_to("TargetState", {})

func _set_oc(new, old):
	print(str(workstation) + ": WORK DONE")
	character.targets.clear()
	workstation.stop_worker_interact()
	WorkstationManager.release_workstation(workstation.type, workstation)
	state_machine.transition_to("TargetState", {})
