extends StaticBody2D
class_name Workstation

signal work_done
signal customer_work_done

var worker_interacting: bool = false
@onready var worker_position: Marker2D = $WorkerPosition
@export var type:WorkstationManager.WORKSTATION
@onready var timer = $Timer
@onready var progress_bar = $ProgressBar

func _ready():
	timer.paused = true
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	WorkstationManager.add_workstation(type, self)

func _process(_delta):
	progress_bar.visible = progress_bar.value >= 10 and progress_bar.value != progress_bar.max_value
	progress_bar.value = ceil((1 - (timer.time_left / timer.wait_time)) * progress_bar.max_value)

func start_worker_interact():
	worker_interacting = true

func stop_worker_interact():
	worker_interacting = false
	WorkstationManager.release_workstation(type, self)

func get_worker_position(): #Returns the position that the worker should aim for
	return worker_position.global_position

func _on_timer_timeout():
	pass
