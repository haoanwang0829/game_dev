extends Node2D
var weapon_radius = 80

# Called when the node enters the scene tree for the first time.
func _ready():
	var weapon_num = get_child_count()
	var unit = TAU/weapon_num
	var weapons = get_children()
	
	for i in len(weapons):
		var weapon = weapons[i]
		var weapon_rad = unit * i
		var end_pos = weapon.position + Vector2(weapon_radius, 0).rotated(weapon_rad)
		weapon.position = end_pos
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var flip = get_parent().get("flip")
	#var weapons = get_children()
	#for weapon in weapons:
		#weapon.get_child(0).flip_h = flip
	pass
