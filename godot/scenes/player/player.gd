extends CharacterBody2D

@export var speed = 4000
@onready var interaction_area = $InteractionArea
@onready var animation_tree = $AnimationTree
var interactables:Array = []
var interacting_object = null

func _physics_process(delta):
	var input_vector = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	if interacting_object != null: #If interacting don't move
		input_vector = Vector2.ZERO
	
	if input_vector != Vector2.ZERO: #Animation
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Walk/blend_position", input_vector)
		animation_tree.get("parameters/playback").travel("Walk")
	else:
		animation_tree.get("parameters/playback").travel("Idle")
	
	velocity = delta * input_vector * speed
	if input_vector != Vector2.ZERO:
		interaction_area.rotation = input_vector.angle() if not (abs(input_vector.y) >= 0.1 and abs(input_vector.y) <= 0.9) else (Vector2(1,0) * sign(input_vector.x)).angle()
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
