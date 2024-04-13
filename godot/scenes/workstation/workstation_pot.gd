extends Workstation

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

func _ready():
	super._ready()
	timer.paused = true
	timer.start()

func _process(_delta):
	progress_bar.value = (1 - (timer.time_left / timer.wait_time)) * progress_bar.max_value

func start_worker_interact():
	super.start_worker_interact()
	timer.paused = false

func stop_worker_interact():
	super.stop_worker_interact()
	timer.paused = true
