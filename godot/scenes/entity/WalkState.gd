extends State
class_name WalkState

@export var character: Entity
@export var speed = 100.0
@export var nav_agent: NavigationAgent2D

var type: Interaction.types
var workstation: Node2D
var target: Vector2

func enter(_msg := {}):
	target = _msg["target"]
	type = _msg["type"]
	workstation = _msg["station"]
	nav_agent.target_position = target
	
	if workstation:
		if character.occupation == character.OCCUPATION.CUSTOMER:
			if !workstation.customer_work_done.is_connected(_on_customer_timeout):
				workstation.customer_work_done.connect(_on_customer_timeout)
		else:
			if !workstation.work_done.is_connected(_on_work_timeout):
				workstation.work_done.connect(_on_work_timeout)
		if workstation.has_signal("leave"):
			if !workstation.leave.is_connected(_on_wait_over):
				workstation.leave.connect(_on_wait_over)
	else:
		state_machine.transition_to("TargetState", {})
	
	if !nav_agent.navigation_finished.is_connected(_on_finished):
		nav_agent.navigation_finished.connect(_on_finished)

func physics_update(_delta:float):
	var dir = character.to_local(nav_agent.get_next_path_position()).normalized()
	character.velocity = dir * speed
	
	if character.human_renderer != null:
		character.human_renderer.update_direction(character.velocity.normalized())
	
	character.move_and_slide()

func _on_work_timeout():
	print(str(workstation) + ": WORK DONE")
	WorkstationManager.release_workstation(workstation.type, workstation)
	state_machine.transition_to("TargetState", {})

func _on_customer_timeout():
	print(str(workstation) + ": CUSTOMER DONE")
	WorkstationManager.release_customer_workstation(workstation.type, workstation)
	state_machine.transition_to("TargetState", {})

func _on_wait_over():
	if character.occupation == character.OCCUPATION.CUSTOMER:
		print(str(workstation) + ": MAD LEAVING")
		state_machine.transition_to("TargetState", {"state": "mad"})
	else:
		print(str(workstation) + ": WORK CANCELED")
		workstation.work_done.emit()
		state_machine.transition_to("TargetState", {})

func _on_finished():
	if workstation.customer_work_done.is_connected(_on_customer_timeout):
		workstation.customer_work_done.disconnect(_on_customer_timeout)
	if workstation.work_done.is_connected(_on_work_timeout):
		workstation.work_done.disconnect(_on_work_timeout)
	if workstation.has_signal("leave"):
		workstation.leave.disconnect(_on_wait_over)
	if type == character.INTERACTION.LEAVE:
		character.queue_free()
	else:
		state_machine.transition_to("InteractState", { "type": type, "station": workstation, "target": target })
