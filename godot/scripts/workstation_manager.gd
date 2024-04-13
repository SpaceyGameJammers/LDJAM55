extends Node

enum WORKSTATION {POT, PAN, TABLE, REGISTER}
var workstations: Dictionary = {}
var customer_workstations: Dictionary = {}

func add_workstation(type: WORKSTATION, workstation:Node):
	if workstations.has(type):
		workstations[type].append(workstation)
	else:
		workstations[type] = [workstation]
	if type == WORKSTATION.TABLE or type == WORKSTATION.REGISTER:
		if customer_workstations.has(type):
			customer_workstations[type].append(workstation)
		else:
			customer_workstations[type] = [workstation]

func occupy_workstation(type: WORKSTATION):
	if type == null:
		return null
	else:
		if workstations.has(type) and len(workstations[type]) >= 1:
			var workstation = workstations[type].front()
			workstations[type].erase(workstation)
			return workstation
		else:
			return null

func occupy_customer_workstation(type: WORKSTATION):
	if type == null:
		return null
	else:
		if customer_workstations.has(type) and len(customer_workstations[type]) >= 1:
			var workstation = customer_workstations[type].front()
			customer_workstations[type].erase(workstation)
			return workstation
		else:
			return null

func release_workstation(type: WORKSTATION, workstation:Node):
	if not workstations[type].has(workstation):
		workstations[type].append(workstation)

func release_customer_workstation(type: WORKSTATION, workstation:Node):
	if not customer_workstations[type].has(workstation):
		customer_workstations[type].append(workstation)

func get_free_workstations_per_type():
	var number_of_free_stations: Dictionary = {}
	for key in workstations.keys():
		number_of_free_stations[key] = len(workstations[key])
	
	return number_of_free_stations

func get_number_of_free_workstations(type: WORKSTATION):
	if workstations.has(type):
		return len(workstations[type])

func get_number_of_free_customer_workstations(type: WORKSTATION):
	if customer_workstations.has(type):
		return len(customer_workstations[type])
