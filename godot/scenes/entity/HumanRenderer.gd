extends Node2D

@export var sprite_sheet : Texture2D = null

@onready var animation_tree = $AnimationTree

func _ready():
	if sprite_sheet != null:
		$Sprite2D.texture = sprite_sheet

func update_direction(direction : Vector2):
	if direction != Vector2.ZERO: #Animation
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)
		animation_tree.get("parameters/playback").travel("Walk")
	else:
		animation_tree.get("parameters/playback").travel("Idle")
