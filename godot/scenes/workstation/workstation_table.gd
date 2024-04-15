extends CustomerWorkstation

signal leave

@onready var food_icon = $FoodIcon

func _process(delta):
	super._process(delta)
	if current_customer != null:
		food_icon.visible = true
	else:
		food_icon.visible = false

func _on_mad_timeout():
	leave.emit()
