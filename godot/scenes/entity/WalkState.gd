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
	
	if !nav_agent.navigation_finished.is_connected(_on_finished):
		nav_agent.navigation_finished.connect(_on_finished)

func physics_update(_delta:float):
	var dir = character.to_local(nav_agent.get_next_path_position()).normalized()
	character.velocity = dir * speed
	
	if character.human_renderer != null:
		character.human_renderer.update_direction(character.velocity.normalized())
	
	character.move_and_slide()


func _on_finished():
	if type == character.INTERACTION.LEAVE:
		character.queue_free()
	else:
		state_machine.transition_to("InteractState", { "type": type, "station": workstation, "target": target })
