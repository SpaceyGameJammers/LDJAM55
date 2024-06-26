extends Workstation
class_name WorkstationPot

@onready var food_icon = $FoodIcon
@onready var sprite = $Sprite2D

@export var has_pot:bool = false

func _process(delta):
	super._process(delta)
	if ResourceManager.raw_carrots == 0:
		stop_worker_interact()

func start_worker_interact():
	if ResourceManager.raw_carrots > 0:
		worker_interacting = true
		timer.paused = false

func stop_worker_interact():
	super.stop_worker_interact()
	timer.paused = true

func _on_timer_timeout():
	ResourceManager.cook_carrots(1)
