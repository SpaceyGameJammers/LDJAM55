extends CustomerWorkstation

@onready var food_icon = $FoodIcon
@onready var mad_timer = $MadTimer

func _process(_delta):
	if current_customer != null:
		food_icon.visible = true
	else:
		food_icon.visible = false
