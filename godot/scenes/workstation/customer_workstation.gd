extends Workstation
class_name CustomerWorkstation

@onready var customer_position = $CustomerPosition
var current_customer = null

func get_customer_position(): #Returns the position that the customer should aim for
	return customer_position.global_position

func customer_interact(customer):
	current_customer = current_customer

func _process(_delta):
	if current_customer != null and worker_interacting:
		current_customer.serve() #Function for customers to notice that they have been served
		current_customer = null
