extends "res://scenes/entity/HumanRenderer.gd"

class_name FloaterRenderer

func _ready():
	pass

func update_direction(direction : Vector2):
	if direction.x < 0:
		$AnimatedSprite2D.scale.x = -1
	else:
		$AnimatedSprite2D.scale.x = 1

func set_texture(_texture: Texture2D):
	pass

func sit(_direction : Vector2):
	pass
