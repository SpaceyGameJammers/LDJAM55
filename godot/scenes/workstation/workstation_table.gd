extends CustomerWorkstation

@onready var food_icon = $FoodIcon

func _process(delta):
	if current_customer != null:
		food_icon.visible = true
	else:
		food_icon.visible = false
