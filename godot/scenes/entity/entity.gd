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
@onready var selection_wheel = $SelectionWheel

enum CHARACTERS { CUSTOMER_1, CUSTOMER_2, WORKER_1 }
enum INTERACTION { ORDER, REGISTER, EAT, WALK, WAIT, COOK_POT, LEAVE, RATE, PAY, TABLE, DISHWASHER, FRYER }
enum OCCUPATION { NONE, REGISTER, CHEF, CUSTOMER, DISHWASHER, FRYER }

var pathing: bool = false
var contact_with_player: bool = false
var player: Player = null

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
	selection_wheel.option_selected.connect(select_occupation_from_wheel)

func _input(event):
	if contact_with_player and event.is_action_pressed("interact") and occupation != OCCUPATION.CUSTOMER:
		selection_wheel.open()
		player.stop()

func set_occupation(new_job:OCCUPATION):
	var old = occupation
	occupation = new_job
	occupation_changed.emit(occupation, old)

func select_occupation_from_wheel(job_id:int):
	player.resume()
	var new_job:OCCUPATION
	match job_id:
		1:
			new_job = OCCUPATION.NONE
		2:
			new_job = OCCUPATION.CHEF
		3:
			new_job = OCCUPATION.FRYER
		4:
			new_job = OCCUPATION.DISHWASHER
		5:
			new_job = OCCUPATION.NONE
		6:
			new_job = OCCUPATION.NONE
		7:
			new_job = OCCUPATION.REGISTER
	set_occupation(new_job)

func _on_command_area_area_entered(area:Area2D):
	if area.get_parent() is Player:
		contact_with_player = true
		player = area.get_parent()

func _on_command_area_area_exited(area:Area2D):
	if area.get_parent() is Player:
		contact_with_player = false
		player = null
