extends TextureProgressBar

@export var update_signal:String

func _ready():
	ResourceManager.connect(update_signal, update_progress)
	update_progress(0)

func update_progress(procentage):
	value = max_value * procentage
