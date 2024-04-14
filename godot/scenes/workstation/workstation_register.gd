extends CustomerWorkstation

func serve():
	#current_customer.give_table()#a function to assign table to customer
	#var table = WorkstationManager.occupy_customer_workstation(WorkstationManager.WORKSTATION.TABLE) #Temporary should be deleted when actual customers exist
	#table.current_customer = 1 #Temporary should be deleted when actual customers exist
	if current_customer != null:
		ResourceManager.change_money(4)
		super.serve()
