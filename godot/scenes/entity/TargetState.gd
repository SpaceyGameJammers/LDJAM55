extends State
class_name TargetState

@export var character: Entity

func enter(_msg := {}):
	var target
	var type
	var station:Workstation
	
	if !_msg.has("state"):
		if character.targets.is_empty():
			match character.occupation:
				character.OCCUPATION.CUSTOMER:
					character.targets = character.customer.duplicate()
				character.OCCUPATION.REGISTER:
					character.targets = character.register.duplicate()
				character.OCCUPATION.CHEF:
					character.targets = character.chef.duplicate()
				character.OCCUPATION.DISHWASHER:
					character.targets = character.dishwasher.duplicate()
				character.OCCUPATION.FRYER:
					character.targets = character.fryer.duplicate()
	else:
		character.targets = [character.INTERACTION.LEAVE]
	
	while type == null or target == null:
		print(str(self) + ": " + str(character.targets))
		if !character.targets.is_empty():
			match character.targets[0]:
				character.INTERACTION.ORDER:
					station = WorkstationManager.occupy_customer_workstation(WorkstationManager.WORKSTATION.REGISTER)
					type = character.INTERACTION.ORDER
					if station:
						target = station.get_customer_position()
					else:
						print("No register found")
				character.INTERACTION.WAIT:
					station = WorkstationManager.occupy_customer_workstation(WorkstationManager.WORKSTATION.TABLE)
					type = character.INTERACTION.WAIT
					if station:
						target = station.get_customer_position()
					else:
						print("No table found")
				character.INTERACTION.LEAVE:
					type = character.INTERACTION.LEAVE
					target = character.leave.global_position
				character.INTERACTION.COOK_POT:
					type = character.INTERACTION.COOK_POT
					station = WorkstationManager.occupy_workstation(WorkstationManager.WORKSTATION.POT)
					if station:
						target = station.get_worker_position()
				character.INTERACTION.REGISTER:
					type = character.INTERACTION.REGISTER
					station = WorkstationManager.occupy_workstation(WorkstationManager.WORKSTATION.REGISTER)
					if station:
						target = station.get_worker_position()
				character.INTERACTION.TABLE:
					type = character.INTERACTION.TABLE
					station = WorkstationManager.occupy_workstation(WorkstationManager.WORKSTATION.TABLE)
					if station:
						target = station.get_worker_position()
			character.targets.remove_at(0)
		else:
			break
		
	if target:
		state_machine.transition_to("WalkState", 
		{ 
			"type": type, 
			"target": target, 
			"station": station 
		})
	else:
		print("No target")

func exit():
	character.pathing = true
