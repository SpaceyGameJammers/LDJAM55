extends HBoxContainer

@export var resource_name:String = "Resource"

@onready var resource_label = $Resource
@onready var counter_label = $Counter


func _ready():
	resource_label.text = resource_name + ":"
