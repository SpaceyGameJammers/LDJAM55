extends HBoxContainer

enum RESOURCE_ICON {MEAT, FISH, POTATO, CARROT, BREAD, MUSHROOM, WINE, TENTACLE}

const icon_size = Vector2i(8, 8)
const atlas_size = Vector2i(2, 4)

@export var resource_icon:RESOURCE_ICON = RESOURCE_ICON.MEAT
@export var reverse_layout:bool = false

@onready var resource_text_rect = $TextureRect
@onready var counter_label = $Counter


func _ready():
	resource_text_rect.texture.region = Rect2((resource_icon % atlas_size.x) * icon_size.x, int(resource_icon / atlas_size.x)*icon_size.y, icon_size.x, icon_size.y)
	ResourceManager.money_update.connect(update_amount)
	update_amount(0)
	if reverse_layout:
		alignment = BoxContainer.ALIGNMENT_END
		var temp = get_child(0)
		remove_child(temp)
		add_child(temp)

func update_amount(amount):
	if reverse_layout:
		counter_label.text = str(amount)+":"
	else:
		counter_label.text = ":"+str(amount)
