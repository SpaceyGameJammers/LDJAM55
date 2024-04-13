extends Node

enum WORKSTATION {POT, PAN, TABLE, REGISTER}
var workstations: Dictionary = {}

func add_workstation(type: WORKSTATION, workstation:Node):
	if workstations.has(type):
		workstations[type].append(workstation)
	else:
		workstations[type] = [workstation]

func occupy_workstation(type: WORKSTATION):
	if type == null:
		return null
	else:
		if len(workstations[type]) >= 1:
			var workstation = workstations[type].front()
			workstations[type].erase(workstation)
			return workstation
		else:
			return null

func release_workstation(type: WORKSTATION, workstation:Node):
	if workstations[type].has(workstation):
		workstations[type].append(workstation)

func get_free_workstations_per_type():
	var number_of_free_stations: Dictionary = {}
	for key in workstations.keys():
		number_of_free_stations[key] = len(workstations[key])
	
	return number_of_free_stations
