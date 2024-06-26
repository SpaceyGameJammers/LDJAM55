extends Node2D
class_name HumanRenderer

@export var sprite_sheet : Texture2D = null

@onready var animation_tree = $AnimationTree

var sitting = false

func _ready():
	if sprite_sheet != null:
		$Sprite2D.texture = sprite_sheet

func set_texture(texture: Texture2D):
	$Sprite2D.texture = texture

func update_direction(direction : Vector2):
	if direction != Vector2.ZERO:
		sitting = false
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)
		animation_tree.get("parameters/playback").travel("Walk")
	else:
		if not sitting:
			animation_tree.get("parameters/playback").travel("Idle")

func sit(direction : Vector2):
	sitting = true
	animation_tree.set("parameters/Sit/blend_position", direction)
	animation_tree.get("parameters/playback").travel("Sit")
