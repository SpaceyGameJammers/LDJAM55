extends Node
class_name Interaction

signal done

enum types { ORDER, EAT, WALK, COOK, LEAVE, RATE, PAY }

@export var timer: Timer
@export var type: types
@export var target: Vector2

func _init(TIME: float, TYPE: types):
	timer = Timer.new()
	timer.wait_time = TIME
	timer.start()
	type = TYPE
	
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	done.emit()
