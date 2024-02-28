extends Node2D

@onready var tilemap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	random_tile()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func random_tile():
	tilemap.clear_layer(1)
	var bg1_cells = tilemap.get_used_cells(0)
	var ran = RandomNumberGenerator.new()
	for cell_pos in bg1_cells:
		var num = ran.randi_range(0, 100)
		if num<4:
			tilemap.set_cell(1, cell_pos, 0, Vector2i(8, 7))
		elif num<8:
			tilemap.set_cell(1, cell_pos, 0, Vector2i(11, 7))
		elif num<9:
			tilemap.set_cell(1, cell_pos, 0, Vector2i(3, 8))
	pass


func _on_button_pressed():
	random_tile()
