extends Workstation

@onready var food_icon = $FoodIcon
@onready var sprite = $Sprite2D

@export var has_pot:bool = false

func _process(delta):
	super._process(delta)
	#progress_bar.visible = progress_bar.value >= 10 and progress_bar.value != progress_bar.max_value
	#food_icon.visible = progress_bar.value == progress_bar.max_value
	if ResourceManager.dirty_plates == 0:
		stop_worker_interact()

func start_worker_interact():
	if ResourceManager.dirty_plates > 0:
		worker_interacting = true
		timer.paused = false

func stop_worker_interact():
	super.stop_worker_interact()
	timer.paused = true

func _on_timer_timeout():
	ResourceManager.clean_plate(1)
