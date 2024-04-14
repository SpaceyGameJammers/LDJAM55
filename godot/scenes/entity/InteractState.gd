extends State
class_name InteractState

@export var character: CharacterBody2D
@export var move_speed:float = 10.0

var move_direction:Vector2
var wander_time:float
var timer:Timer
var workstation:Workstation

func enter(_msg := {}):
	timer = Timer.new()
	add_child(timer)
	workstation = _msg["station"]
	if workstation:
		workstation.start_worker_interact()
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = 2.0
	timer.start()

func _on_timer_timeout():
	remove_child(timer)
	timer.queue_free()
	state_machine.transition_to("TargetState", {})

func exit():
	if workstation:
		workstation.stop_worker_interact()
