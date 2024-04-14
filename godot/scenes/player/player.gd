extends CharacterBody2D

@export var speed = 4000
@onready var interaction_area = $InteractionArea
var interactables:Array = []
var interacting_object = null

func _physics_process(delta):
	var input_vector = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	if interacting_object != null: #If interacting don't move
		input_vector = Vector2.ZERO
	
	$HumanRenderer.update_direction(input_vector)
	
	velocity = delta * input_vector * speed
	if input_vector != Vector2.ZERO:
		
		interaction_area.rotation = roundf(input_vector.angle()/(PI/2)) * PI/2 if not is_equal_approx(absf(input_vector.x), absf(input_vector.y)) else Vector2(sign(input_vector.x), 0).angle()#floorf((input_vector.angle()+(PI/4))/(PI/2)) * PI/2
	move_and_slide()

func _process(_delta):
	if interacting_object == null and Input.is_action_pressed("interact") and not interactables.is_empty():
		for interactable in interactables: #Find the closest interactable object
			if interacting_object == null or global_position.distance_squared_to(interacting_object.global_position) > global_position.distance_squared_to(interactable.global_position):
				interacting_object = interactable
		interacting_object.start_worker_interact()
	if interacting_object != null and Input.is_action_just_released("interact"):
		interacting_object.stop_worker_interact()
		interacting_object = null

func _on_interaction_area_area_entered(area):
	if not interactables.has(area):
		interactables.append(area)

func _on_interaction_area_area_exited(area):
	if interactables.has(area):
		interactables.erase(area)

func _on_interaction_area_body_entered(body):
	if not interactables.has(body):
		interactables.append(body)

func _on_interaction_area_body_exited(body):
	if interactables.has(body):
		interactables.erase(body)
