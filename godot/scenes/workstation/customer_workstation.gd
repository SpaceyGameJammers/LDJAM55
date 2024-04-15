extends Workstation
class_name CustomerWorkstation

@onready var customer_position = $CustomerPosition
@onready var timer:Timer = $Timer
var current_customer = null

func _ready():
	super._ready()
	timer.paused = true
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func get_customer_position(): #Returns the position that the customer should aim for
	return customer_position.global_position

func customer_interact(customer):
	current_customer = customer

func start_worker_interact():
	if current_customer != null:
		print(str(self) + ": Started working")
		timer.paused = false
		super.start_worker_interact()

func stop_worker_interact():
	if current_customer != null:
		timer.paused = true
		super.stop_worker_interact()

func serve():
	timer.paused = true
	current_customer = null
	WorkstationManager.release_customer_workstation(type, self)
	super.emit_signal("customer_work_done")
	super.emit_signal("work_done")

func _on_timer_timeout():
	serve()
