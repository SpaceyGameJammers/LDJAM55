extends CustomerWorkstation

signal leave

@onready var food_icon = $FoodIcon
@onready var mad_timer = $MadTimer

func _ready():
	super._ready()
	mad_timer.paused = true
	mad_timer.start()
	mad_timer.timeout.connect(_on_timer_timeout)

func _process(_delta):
	if current_customer != null:
		food_icon.visible = true
	else:
		food_icon.visible = false

func _on_timer_timeout():
	leave.emit()
