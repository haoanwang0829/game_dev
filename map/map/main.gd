extends Node2D
@onready var tilemap = $TileMap


func _ready():
	tilemap.initiate_map()
	#print(tilemap.get_cells_by_id(0))
