extends Node2D

@export var min_spawntime:float = 10.0
@export var max_spawntime:float = 30.0
@export var variation: float = 0.05
@export var customer_scene:PackedScene
@export var customer_textures:Array[Texture2D]

@onready var timer:Timer = $Timer
@onready var enter_point = $EnterPoint
@onready var leave_point = $LeavePoint

func _ready():
	timer.start(max_spawntime*(1-ResourceManager.get_rating()))

func _on_timer_timeout():
	var customer = customer_scene.instantiate()
	customer.sprite_sheet = customer_textures[randi() % customer_textures.size()]
	customer.occupation = customer.OCCUPATION.CUSTOMER
	get_parent().add_child(customer)
	customer.global_position = enter_point.global_position
	customer.leave = leave_point
	var random_variation = randf_range(0, variation)
	var spawn_time = max(min_spawntime, max_spawntime * (1-ResourceManager.get_rating())) * random_variation
	timer.start()
