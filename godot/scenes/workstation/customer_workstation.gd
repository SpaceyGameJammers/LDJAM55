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

func _process(_delta):
	if current_customer != null and worker_interacting:
		serve()

func serve():
	#current_customer.serve() #Function for customers to notice that they have been served
	current_customer = null
	WorkstationManager.release_customer_workstation(type, self)
	timer.paused = false

func _on_timer_timeout():
	timer.paused = true
	timer.start()
	super.emit_signal("work_done")
