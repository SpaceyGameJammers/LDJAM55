extends State
class_name TargetState

@export var character: Entity

func enter(_msg := {}):
	print("TARGET")
	var target
	var type
	
	if !character.targets.is_empty():
		while type == null:
			match character.targets[0]:
				character.INTERACTION.ORDER:
					type = character.INTERACTION.ORDER
					target = character.order.global_position
				character.INTERACTION.EAT:
					type = character.INTERACTION.EAT
					target = character.eat.global_position
				character.INTERACTION.LEAVE:
					type = character.INTERACTION.LEAVE
					target = character.leave.global_position
			
			character.targets.remove_at(0)
		
		state_machine.transition_to("WalkState", { "type": type, "target": target })

func exit():
	character.pathing = true
