extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func run_animation(options):
	if !options.has("box"):
		options.box = GameMain.duplicate_node
	var ani_temp = self.duplicate()
	options.box.add_child(ani_temp)
	ani_temp.show()
	ani_temp.scale = options.scale if options.has("scale") else Vector2(1, 1)
	ani_temp.position = options.position
	ani_temp.get_node("all_animation").play(options.ani_name)

func _on_all_animation_animation_finished():
	self.queue_free()# Replace with function body.
