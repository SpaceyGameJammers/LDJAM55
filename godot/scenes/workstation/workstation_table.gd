extends CustomerWorkstation

signal leave

@onready var food_icon = $FoodIcon

func _process(delta):
	super._process(delta)
	if current_customer != null:
		if not food_icon.visible:
			food_icon.frame = randi() % (food_icon.hframes*food_icon.vframes - 1)
		food_icon.visible = true
	else:
		food_icon.visible = false

func _on_mad_timeout():
	leave.emit()
