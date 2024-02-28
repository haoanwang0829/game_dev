class_name Cell

var id: int
var pos: Vector2
var is_visit : bool = false
var distance_to_center: int
var tile: int
var elevation: int
var double_pos: Vector2
var is_river: bool = false

func _init(id, pos):
	self.id = id
	self.pos = pos
	self.elevation = 0
	self.convert_double_pos()

func convert_double_pos():
	if int(pos.y) % 2 == 0:
		double_pos.x = pos.x*2
	else:
		double_pos.x = pos.x*2 + 1
	double_pos.y = pos.y

func check_direction(cell):
	var direction_dict = {
		Vector2(1,-1): 0,
		Vector2(2,0): 1,
		Vector2(1,1): 2,
		Vector2(-1,1): 3,
		Vector2(-2,0): 4,
		Vector2(-1,-1): 5
	}
	var diff = cell.double_pos - self.double_pos
	return direction_dict[diff]
	
#func get_surrunding():
	#surrunding_
	#for pos in tilemap.get_surrounding_cells(self.pos):
		#pass
