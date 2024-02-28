extends TileMap

var map_x_index = 40
var map_y_index = 40

var cell_map = []
var cell_boader = []

var landPercentage = 0.5
var jitterProbability = 0.5
var chuckSizeMin = 15
var chuckSizeMax = 25
var waterLevel = 3
var highRiseProbability = 0.25
var sinkProbability = 0.25
var mapBorderX = 4
var mapBorderY = 4
var iterMax = 10000
var erosionPercentage = 0.2
var rand = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
			
func init_base():
	self.clear_layer(0)
	for _y in range(map_y_index):
		for _x in range(map_x_index):
			var id = _y*map_x_index + _x
			var new_position = Vector2(_x, _y)
			var new_cell = Cell.new(id, new_position)
			cell_map.append(new_cell)
			self.set_cell_tile(new_cell, 0, 0, Vector2i(0, 0))

func get_cell_by_pos(pos):
	return cell_map[pos.y*map_x_index + pos.x]

func clear_visit():
	for i in cell_map:
		i.is_visit = false
		
func setTerrainType():
	for cell in cell_map:
		var elevation = cell.elevation - waterLevel + 1
		elevation = 8 if elevation >8 else elevation
		elevation = -2 if elevation <-2 else elevation
		self.set_cell_tile(cell, 0, 0, Vector2i(0, 0), elevation+3)
		
func get_surrounding_cells_(cell, check_visit=false):
	var out = []
	for cell_pos in get_surrounding_cells(cell.pos):
		if cell_pos.y*map_x_index + cell_pos.x < cell_map.size():
			cell = get_cell_by_pos(cell_pos)
			if check_visit:
				if !cell.is_visit:
					out.append(get_cell_by_pos(cell_pos))
			else:
				out.append(get_cell_by_pos(cell_pos))
	return out

func set_cell_tile(cell, layer, source_id, atlas_coords, alternative_tile=0):
	cell.tile = 0
	self.set_cell(layer, cell.pos, source_id, atlas_coords, alternative_tile)
			
func modify_terrain():
	var chunkCount = landPercentage*cell_map.size()
	var iter = 0
	while chunkCount > 0 and iter < iterMax:
		var random_center_x = rand.randi_range(mapBorderX, map_x_index-mapBorderX-1)
		var random_center_y = rand.randi_range(mapBorderY, map_y_index-mapBorderY-1)
		var random_center_position = random_center_y*map_x_index + random_center_x
		var chuckSize = rand.randi_range(chuckSizeMin, chuckSizeMax)
		if rand.randf_range(0, 1)<sinkProbability:
			chunkCount = sink_chunk(random_center_position, chuckSize, chunkCount)
		else:
			chunkCount = generate_chunk(random_center_position, chuckSize, chunkCount)
		iter += 1	
	erode_cells()
	
func generate_chunk(center_position, chunk_num, chunkCount):
	var out = []
	clear_visit()
	var center_cell = cell_map[center_position]
	center_cell.is_visit = true
	out.append(center_cell)
	var c = 0
	var rise = 2 if rand.randf_range(0, 1)<highRiseProbability else 1
	while c < out.size() and len(out) < chunk_num and chunkCount>0:
		var surrounding_cells = get_surrounding_cells_(out[c], true)
		for cell in surrounding_cells:
			if len(out) < chunk_num and chunkCount > 0:
				if rand.randf_range(0, 1) < jitterProbability:
					var old_elevation = cell.elevation
					cell.elevation += rise
					if old_elevation < waterLevel and cell.elevation >= waterLevel:
						chunkCount -= 1 
					cell.is_visit = true
					out.append(cell)
		c += 1
	return chunkCount
	
func sink_chunk(center_position, chunk_num, chunkCount):
	var out = []
	clear_visit()
	var center_cell = cell_map[center_position]
	center_cell.is_visit = true
	out.append(center_cell)
	var c = 0
	var sink = 2 if rand.randf_range(0, 1)<highRiseProbability else 1
	while c < out.size() and len(out) < chunk_num and chunkCount>0:
		var surrounding_cells = get_surrounding_cells_(out[c], true)
		for cell in surrounding_cells:
			if len(out) < chunk_num and chunkCount > 0:
				if rand.randf_range(0, 1) < jitterProbability:
					var old_elevation = cell.elevation
					cell.elevation -= sink
					if old_elevation >= waterLevel and cell.elevation < waterLevel:
						chunkCount += 1 
					cell.is_visit = true
					out.append(cell)
		c += 1
	return chunkCount
	
func check_erodible(cell):
	var candidates = []
	var erodibleElevation = cell.elevation - 2
	var surrounding_cells = get_surrounding_cells_(cell, false)
	for neighbor_cell in surrounding_cells:
		if neighbor_cell.elevation <= erodibleElevation:
			candidates.append(neighbor_cell)
	if candidates.size() > 0:
		return [true, candidates.pick_random()]
	else:
		return [false, null]
	
func erode_cells():
	var erode_cells = {}
	for cell in cell_map:
		var check_out = check_erodible(cell)
		if check_out[0]:
			erode_cells[cell] = check_out[1]
	var targetErodibleCount = erode_cells.size() * erosionPercentage
	while erode_cells.size() > targetErodibleCount:
		var select_cell = erode_cells.keys()[rand.randi_range(0, erode_cells.size()-1)]
		var candidates = erode_cells[select_cell]
		select_cell.elevation -= 1
		candidates.elevation += 1

		for neighbor_cell in get_surrounding_cells_(select_cell, false) + get_surrounding_cells_(candidates, false):
			var check_out2 = check_erodible(neighbor_cell)
			if check_out2[0]:
				erode_cells[neighbor_cell] = check_out2[1]
			else:
				erode_cells.erase(neighbor_cell)
	
		
func find_lakes():
	var astar = AStar2D.new()
	for cell_index in cell_map.size():
		var cell = cell_map[cell_index]
		if cell.elevation < waterLevel:
			astar.add_point(cell_index, cell.pos)
			var surrounding_cells = get_surrounding_cells_(cell, false)
			for neighbor_cell in surrounding_cells:
				if neighbor_cell.elevation < waterLevel:
					var neighbor_id = neighbor_cell.pos.y*map_x_index + neighbor_cell.pos.x
					astar.add_point(neighbor_id, neighbor_cell.pos)
					astar.connect_points(cell_index, neighbor_id)
	
	for id in astar.get_point_ids():
		var path_out = astar.get_point_path(id, 0)
		if path_out.size() == 0:
			self.set_cell_tile(cell_map[id], 1, 1, Vector2i(0, 0), 1)

func river_next_cell(path, cell, riverBudget):
	if riverBudget <= 0:
		return path
	if cell.elevation < waterLevel:
		return path
	var possible_cells = {"down":[], 'flat':[], 'up':[]}
	var surrounding_cells = get_surrounding_cells_(cell, false)
	for neighbor_cell in surrounding_cells:
		if cell.elevation > neighbor_cell.elevation:
			possible_cells['down'].append(neighbor_cell)
		if cell.elevation == neighbor_cell.elevation:
			possible_cells['flat'].append(neighbor_cell)
		if cell.elevation < neighbor_cell.elevation:
			possible_cells['up'].append(neighbor_cell)
	if possible_cells['down'].size() > 0:
		var next_cell = possible_cells['down'].pick_random()
		path.append(next_cell)
		next_cell.is_river = true
		return river_next_cell(path, next_cell, riverBudget) 
	elif possible_cells['flat'].size() > 0:
		var next_cell = possible_cells['flat'].pick_random()
		path.append(next_cell)
		next_cell.is_river = true
		return river_next_cell(path, next_cell, riverBudget-1) 
	else:
		return path
				
	
func init_river():
	var river_dict = {}
	var possible_start = []
	for cell in cell_map:
		if rand.randf_range(0, cell.elevation - waterLevel) >= 4:
			possible_start.append(cell)
	
	var i = 0
	while i < possible_start.size()-1:
		var j = i+1
		while j < possible_start.size():
			if possible_start[i].pos.distance_to(possible_start[j].pos) < 3:
				possible_start.remove_at(j)
			else:
				j += 1
		i += 1
				
	for cell in possible_start:
		if cell.is_river == true:
			continue
		cell.is_river = true
		var path = [cell]
		path = river_next_cell(path, cell, rand.randi_range(5, 10))
		river_dict[cell] = path
	for cell in river_dict.keys():
		var p = 0
		var path = river_dict[cell]
		while p < path.size()-1:
			var this_cell = path[p]
			var next_cell = path[p+1]
			if p == 0:
				var direction = this_cell.check_direction(next_cell)
				self.set_cell_tile(this_cell, 2, 2, Vector2i(direction, 0))
			else:
				if p+1 == path.size()-1 and !next_cell.elevation < waterLevel:
					var direction = next_cell.check_direction(this_cell)
					if get_cell_tile_data(2, next_cell.pos):
						self.set_cell_tile(next_cell, 3, 2, Vector2i(direction, 0))
						break
					else:
						self.set_cell_tile(next_cell, 2, 2, Vector2i(direction, 0))
				var previous_cell = path[p-1]
				var first_direction = this_cell.check_direction(previous_cell)
				var second_direction = this_cell.check_direction(next_cell)
				if get_cell_tile_data(2, this_cell.pos):
					self.set_cell_tile(this_cell, 3, 3, Vector2i(first_direction, second_direction))
					break
				else:
					self.set_cell_tile(this_cell, 2, 3, Vector2i(first_direction, second_direction))
			p += 1
		
func generate_map():
	rand.set_seed(2024)
	init_base()
	modify_terrain()
	setTerrainType()
	find_lakes()
	init_river()
			
func initiate_map():
	generate_map()
