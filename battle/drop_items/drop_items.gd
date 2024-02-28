extends CharacterBody2D

var canMoving = false
var speed = 1500
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	self.set_collision_layer_value(5, false)
	
	player = get_tree().get_first_node_in_group("player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if canMoving:
		var direction = self.position.direction_to(player.position)
		velocity = direction * speed
		move_and_slide()

func generate_drop_item(options):
	if !options.has("box"):
		options.box = GameMain.duplicate_node
		
	var ani_temp = self.duplicate()
	options.box.add_child.call_deferred(ani_temp)
	ani_temp.show.call_deferred()
	ani_temp.set_collision_layer_value.call_deferred(5, true)
	ani_temp.scale = options.scale if options.has("scale") else Vector2(1, 1)
	ani_temp.position = options.position
	ani_temp.get_node("all_animation").play(options.ani_name)
