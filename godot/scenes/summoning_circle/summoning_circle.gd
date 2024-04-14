extends Area2D

var summoning_song: AudioStream = load("res://audio/summon_song.wav")
var accessable = false
@onready var selection_wheel = $SelectionWheel
@onready var shader = $Graphics
@onready var ring1_img = $Ring1Albedo
@onready var ring2_img = $Ring2Albedo
@onready var hex_img = $HexAlbedo
@export var eldriches: Array[PackedScene]
@export var sprites: Array[Texture2D]

var rotation_speed = 1
var img_rotation = PI / 261.375
var floatrender = preload("res://scenes/entity/FloaterRenderer.tscn")

func _ready():
	if OS.has_feature("web"):
		ring1_img.visible = true
		ring2_img.visible = true
		hex_img.visible = true
		shader.visible = false
	else:
		ring1_img.visible = false
		ring2_img.visible = false
		hex_img.visible = false
		shader.visible = true
	
	selection_wheel.option_selected.connect(end_summoning)
	(shader.material as ShaderMaterial).set_shader_parameter("speed", rotation_speed)
	pass

func end_summoning(eldrich_id):
	(shader.material as ShaderMaterial).set_shader_parameter("speed", rotation_speed)
	if eldrich_id == 0:
		return
	MusicManager.change_music(summoning_song)
	var eldirch = eldriches[eldrich_id - 1].instantiate()
	print_debug(eldrich_id)
	if eldrich_id - 1 == 2:
		eldirch.human_renderer.queue_free()
		eldirch.add_child(floatrender.instantiate())
	else:
		eldirch.sprite_sheet = sprites[eldrich_id - 1]
	get_parent().add_child(eldirch)
	eldirch.global_position = self.global_position

func _process(delta):
	if OS.has_feature("web"):
		ring1_img.rotate(-rotation_speed * img_rotation)
		ring2_img.rotate(rotation_speed * img_rotation)

func _input(event:InputEvent):
	if accessable and event.is_action_pressed("interact"):
		rotation_speed = 1
		(shader.material as ShaderMaterial).set_shader_parameter("speed", rotation_speed)
		selection_wheel.open()

func _on_area_entered(_area):
	accessable = true

func _on_area_exited(_area):
	accessable = false
