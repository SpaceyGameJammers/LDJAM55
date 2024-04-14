extends CharacterBody2D
class_name Entity

@export var speed = 100.0
@export var target: Node2D
@export var nav_agent: NavigationAgent2D
@export var occupation: OCCUPATION

@export var order: Node2D
@export var eat: Node2D
@export var leave: Node2D

@onready var wait_timer: Timer = $WaitTimer

enum INTERACTION { ORDER, REGISTER, EAT, WALK, WAIT, COOK_POT, LEAVE, RATE, PAY, TABLE }
enum OCCUPATION { REGISTER, CHEF, CUSTOMER }

var pathing: bool = false

var register = [
	INTERACTION.REGISTER,
	INTERACTION.TABLE
]

var customer = [
	INTERACTION.ORDER,
	INTERACTION.WALK,
	INTERACTION.WAIT,
	INTERACTION.EAT,
	INTERACTION.LEAVE,
]

var targets = [
]

#func _physics_process(_delta):
	#var dir = to_local(nav_agent.get_next_path_position()).normalized()
	#print("DIR: " + str(dir))
	#velocity = dir * speed
	#
	#move_and_slide()
#
#func pathfind():
	#nav_agent.target_position = target.global_position
#
#func _on_timer_timeout():
	#pathfind()
#
#func _on_navigation_agent_2d_target_reached():
	#pathing = false
