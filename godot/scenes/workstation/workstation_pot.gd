extends StaticBody2D

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

var interacting: bool = false
var type = "pot"

func _ready():
	timer.paused = true
	timer.start()
	WorkstationManager.add_workstation(type, self)

func _process(_delta):
	progress_bar.value = (1 - (timer.time_left / timer.wait_time)) * progress_bar.max_value

func start_interact():
	interacting = true
	timer.paused = false

func stop_interact():
	interacting = false
	timer.paused = true
	WorkstationManager.release_workstation(type, self)
