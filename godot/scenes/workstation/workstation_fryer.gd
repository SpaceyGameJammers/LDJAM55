extends Workstation

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer
@onready var food_icon = $FoodIcon
@onready var sprite = $Sprite2D

@export var has_pot:bool = false

func _ready():
	super._ready()
	timer.paused = true
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func _process(_delta):
	progress_bar.visible = progress_bar.value >= 10 and progress_bar.value != progress_bar.max_value
	food_icon.visible = progress_bar.value == progress_bar.max_value
	progress_bar.value = ceil((1 - (timer.time_left / timer.wait_time)) * progress_bar.max_value)
	if ResourceManager.raw_potatoes == 0:
		stop_worker_interact()

func start_worker_interact():
	if ResourceManager.raw_potatoes > 0:
		worker_interacting = true
		timer.paused = false

func stop_worker_interact():
	super.stop_worker_interact()
	timer.paused = true

func _on_timer_timeout():
	ResourceManager.cook_potatoes(1)
	super.emit_signal("work_done")
