extends StaticBody2D
class_name Workstation

var worker_interacting: bool = false
@onready var worker_position: Marker2D = $WorkerPosition
@export var type:WorkstationManager.WORKSTATION

func _ready():
	WorkstationManager.add_workstation(type, self)

func start_worker_interact():
	worker_interacting = true

func stop_worker_interact():
	worker_interacting = false
	WorkstationManager.release_workstation(type, self)

func get_worker_position(): #Returns the position that the worker should aim for
	return worker_position.global_position
