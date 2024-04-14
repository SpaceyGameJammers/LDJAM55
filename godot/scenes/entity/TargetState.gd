extends State
class_name TargetState

@export var character: Entity

func enter(_msg := {}):
	print("TARGET")
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
			print(str(character.targets))
	else:
		character.targets = [character.INTERACTION.LEAVE]
	
	if !character.targets.is_empty():
		while type == null or target == null:
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
			
			character.targets.remove_at(0)
		
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
