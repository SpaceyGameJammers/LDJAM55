extends CustomerWorkstation

func _process(delta): #This is temporary for test
	if WorkstationManager.get_number_of_free_customer_workstations(WorkstationManager.WORKSTATION.TABLE) > 0:
		current_customer = 1
	else:
		current_customer = null

func serve():
	#current_customer.give_table()#a function to assign table to customer
	#var table = WorkstationManager.occupy_customer_workstation(WorkstationManager.WORKSTATION.TABLE) #Temporary should be deleted when actual customers exist
	#table.current_customer = 1 #Temporary should be deleted when actual customers exist
	if current_customer:
		ResourceManager.add_money(4)
		super.serve()
