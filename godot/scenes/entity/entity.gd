extends CharacterBody2D

@export var speed = 100.0
@export var target: Node2D
@export var nav_agent: NavigationAgent2D

func _physics_process(_delta):
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	print("DIR: " + str(dir))
	velocity = dir * speed
	
	move_and_slide()

func pathfind():
	nav_agent.target_position = target.global_position

func _on_timer_timeout():
	pathfind()
