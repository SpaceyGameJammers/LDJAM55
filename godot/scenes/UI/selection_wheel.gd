@tool
extends Control

signal option_selected(option:int)

const SPRITE_SIZE = Vector2(16, 16)

@export var bkg_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var line_width: int = 4

@export var option_images: Array[AtlasTexture]

var selection = null

func _ready():
	visible = false
	set_process(false)

func open():
	visible = true
	set_process(true)

func close():
	option_selected.emit(selection)
	selection = null
	visible = false
	set_process(false)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and is_processing():
		close()

func _process(_delta):
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius < inner_radius:
		selection = 0
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1 - PI/2, TAU)
		selection = ceil((mouse_rads / TAU) * (len(option_images) - 1))
	queue_redraw()

func _draw():
	var offset = SPRITE_SIZE / -2
	
	draw_circle(Vector2.ZERO, outer_radius, bkg_color)
	
	if selection == 0:
		draw_circle(Vector2.ZERO, inner_radius, highlight_color)
	
	draw_texture_rect_region(option_images[0].atlas, Rect2(offset, SPRITE_SIZE), option_images[0].region)
	for i in range(1, len(option_images)):
		var start_rads = (TAU * (i - 1)) / (len(option_images) - 1) + PI/2
		var end_rads = (TAU * (i)) / (len(option_images) - 1) + PI/2
		var mid_rads = (start_rads + end_rads)/2.0 * -1
		var radius_mid = (inner_radius + outer_radius) / 2.0
		
		if selection == i:
			var points_per_arc = 32
			var points_inner = PackedVector2Array()
			var points_outer = PackedVector2Array()
			for j in range((points_per_arc + 1)):
				var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
				points_inner.append(inner_radius * Vector2.from_angle(TAU-angle))
				points_outer.append(outer_radius * Vector2.from_angle(TAU-angle))
			points_outer.reverse()
			draw_polygon(points_inner + points_outer, PackedColorArray([highlight_color]))
		
		var draw_pos = radius_mid * Vector2.from_angle(mid_rads) + offset
		draw_texture_rect_region(option_images[i].atlas, Rect2(draw_pos, SPRITE_SIZE), option_images[i].region)
	# draw separator lines
	for i in range(len(option_images) - 1):
		var rads = TAU * i/(len(option_images) - 1) - PI/2
		var point = Vector2.from_angle(rads)
		draw_line(point*inner_radius, point*outer_radius, line_color, line_width, true)
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, line_width, true)
