extends State
class_name InteractState

@export var character: CharacterBody2D
@export var move_speed:float = 10.0

var move_direction:Vector2
var wander_time:float
var timer:Timer

func enter(_msg := {}):
	print("INTERACT")
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = 2.0
	timer.start()

func _on_timer_timeout():
	print("INTERACT DONE")
	remove_child(timer)
	timer.queue_free()
	state_machine.transition_to("TargetState", {})
