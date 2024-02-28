extends CharacterBody2D

@onready var playerAni = $playerAni

var direction = Vector2.ZERO
var speed = 700
var flip = false
var canMove = true
var stop = false

# Called when the node enters the scene tree for the first time.
func _ready():
	choosePlayer('player2')

func choosePlayer(player):
	playerAni.sprite_frames.clear_all()
	
	var player_path = "res://asset/player/" + player 
	var type_list = ["walk", "death", "roll"]
	var sprite_frame_custom = SpriteFrames.new()
	for type in type_list:
		sprite_frame_custom.add_animation(type)
		var pics_list = DirAccess.open('/'.join([player_path,type])).get_files()
		for pic in pics_list:
			if !pic.ends_with('import'):
				var texture: Texture = load('/'.join([player_path,type,pic]))
				var frame = AtlasTexture.new()
				frame.atlas = texture
				frame.region = Rect2(Vector2(0, 0), Vector2(2048, 2048))
				sprite_frame_custom.add_frame(type, frame)
		sprite_frame_custom.set_animation_speed(type, 10)
		if type == 'walk':
			sprite_frame_custom.set_animation_loop("walk", true)
	playerAni.sprite_frames = sprite_frame_custom
	playerAni.play('walk')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var self_pos = position
	
	if mouse_pos.x >= position.x:
		flip = false
	else:
		flip = true
	
	playerAni.flip_h = flip
	
	direction = (mouse_pos - self_pos).normalized()
	
	if canMove and !stop:
		velocity = direction * speed
		move_and_slide()
		playerAni.play()
	else:
		playerAni.pause()
	pass
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		canMove=false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.is_pressed():
		canMove=true


func _on_stop_mouse_entered():
	stop=true


func _on_stop_mouse_exited():
	stop=false # Replace with function body.


func _on_pick_area_body_entered(body):
	if body.is_in_group("drop_items"):
		body.canMoving = true

func _on_stop_body_entered(body):
	if body.is_in_group("drop_items"):
		body.queue_free()

