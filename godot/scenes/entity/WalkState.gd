extends State
class_name WalkState

@export var character: CharacterBody2D
@export var speed = 100.0
@export var nav_agent: NavigationAgent2D

var type: Interaction.types

func enter(_msg := {}):
	nav_agent.target_position = _msg["target"] 
	type = _msg["type"]
	if !nav_agent.navigation_finished.is_connected(_on_finished):
		nav_agent.navigation_finished.connect(_on_finished)

func physics_update(delta:float):
	var dir = character.to_local(nav_agent.get_next_path_position()).normalized()
	character.velocity = dir * speed
	
	character.move_and_slide()

func _on_finished():
	print("WALKED")
	state_machine.transition_to("InteractState", { "type": type })
