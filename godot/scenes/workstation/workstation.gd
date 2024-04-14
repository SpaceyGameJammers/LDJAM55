extends StaticBody2D

signal work_done

var worker_interacting: bool = false

@onready var worker_position: Marker2D = $WorkerPosition
@onready var timer: Timer = $Timer
@onready var progress_bar = $ProgressBar
@onready var food_icon = $FoodIcon

@export var type:WorkstationManager.WORKSTATION

func _ready():
	WorkstationManager.add_workstation(type, self)
	if timer:
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)

func _process(_delta):
	if progress_bar:
		progress_bar.visible = progress_bar.value != 0 and progress_bar.value != progress_bar.max_value
		if progress_bar.value < progress_bar.max_value:
			progress_bar.value = ceil((1 - (timer.time_left / timer.wait_time)) * progress_bar.max_value)
		if food_icon:
			food_icon.visible = progress_bar.value == progress_bar.max_value

func start_worker_interact():
	worker_interacting = true
	if timer:
		timer.start()

func stop_worker_interact():
	worker_interacting = false
	WorkstationManager.release_workstation(type, self)

func get_worker_position(): #Returns the position that the worker should aim for
	if worker_position:
		return worker_position.global_position
	else:
		return global_position

func _on_timer_timeout():
	print("WORK DONE")
	work_done.emit()
