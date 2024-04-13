extends Workstation
class_name CustomerWorkstation

@onready var customer_position = $CustomerPosition
var current_customer = 1

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
