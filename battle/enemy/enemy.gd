extends CharacterBody2D

var direction = Vector2.ZERO
var speed = 300
var target = null
var hp = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_tree().get_first_node_in_group("player") # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		direction = self.global_position.direction_to(target.global_position)
		velocity = direction * speed
		move_and_slide()
	pass

func enemy_hurt(damage):
	hp -= damage
	enemy_flash()
	
	GameMain.animation_scene_obj.run_animation({
		"box": self,
		"ani_name": "enemy_hurt",
		"position": Vector2(0, -2),
		"scale": Vector2(0.5, 0.5)
	})
	if hp <= 0:
		enemy_dead()
		

func enemy_dead():
	GameMain.animation_scene_obj.run_animation({
		"box": GameMain.duplicate_node,
		"ani_name": "enemy_death",
		"position": self.global_position,
		"scale": Vector2(0.2, 0.2)
	})
	GameMain.drop_items_scene_obj.generate_drop_item({
		"box": GameMain.duplicate_node,
		"ani_name": "coin",
		"position": self.global_position,
		"scale": Vector2(3, 3)
	})
	self.queue_free()
	
func enemy_flash():
	$AnimatedSprite2D.material.set_shader_parameter("flash_opacity", 1)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.material.set_shader_parameter("flash_opacity", 0)
