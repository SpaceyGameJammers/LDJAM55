extends CharacterBody2D
class_name Entity

signal occupation_changed(new:OCCUPATION, old:OCCUPATION)

@export var speed = 100.0
@export var target: Node2D
@export var nav_agent: NavigationAgent2D
@export var occupation: OCCUPATION
@export var human_renderer: HumanRenderer
@export var leave: Node2D
@export var sprite_sheet: Texture2D

@onready var wait_timer: Timer = $WaitTimer

enum CHARACTERS { CUSTOMER_1, CUSTOMER_2, WORKER_1 }
enum INTERACTION { ORDER, REGISTER, EAT, WALK, WAIT, COOK_POT, LEAVE, RATE, PAY, TABLE, DISHWASHER, FRYER }
enum OCCUPATION { NONE, REGISTER, CHEF, CUSTOMER, DISHWASHER, FRYER }

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

var chef = [
	INTERACTION.COOK_POT
]

var dishwasher = [
	INTERACTION.DISHWASHER
]

var fryer = [
	INTERACTION.FRYER
]

var targets = [
]

func _ready():
	human_renderer.set_texture(sprite_sheet)

func set_occupation(new_job:OCCUPATION):
	var old = occupation
	occupation = new_job
	occupation_changed.emit(occupation, old)
