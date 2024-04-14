extends CharacterBody2D
class_name Entity

@export var speed = 100.0
@export var target: Node2D
@export var nav_agent: NavigationAgent2D
@export var occupation: OCCUPATION
@export var human_renderer: Node
@export var leave: Node2D
@export var sprite_sheet: Texture2D

@onready var wait_timer: Timer = $WaitTimer

enum CHARACTERS { CUSTOMER_1, CUSTOMER_2, WORKER_1 }
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

func _ready():
	human_renderer.set_texture(sprite_sheet)

#func pathfind():
	#nav_agent.target_position = target.global_position
#
#func _on_timer_timeout():
	#pathfind()
#
#func _on_navigation_agent_2d_target_reached():
	#pathing = false
