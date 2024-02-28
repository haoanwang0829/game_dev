extends Node2D

@onready var weaponAni = $weaponAni
@onready var shoot_position = $shoot_position
@onready var shoot_cd = $shoot_cd
@onready var muzzle = $muzzle
@onready var muzzle_timer = $muzzle_timer
@onready var bullet = preload("res://bullet/bullet.tscn")

var bullet_shoot_time = 0.5
var bullet_speed = 2000
var bullet_damage = 1

const weapon_level = {
	level_1 = "#ffffff",
	level_2 = "#1eff00",\
	level_3 = "#0070dd",
	level_4 = "#a335ee",
	level_5 = "#ff8000",
}

var attack_enemies = []


# Called when the node enters the scene tree for the first time.
func _ready():
	var rand = RandomNumberGenerator.new()
	weaponAni.material.set_shader_parameter('color', Color(weapon_level['level_' + str(rand.randi_range(1, 5))]))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if attack_enemies.size() != 0:
		self.look_at(attack_enemies[0].position)
	else:
		rotation_degrees = 0


func _on_shoot_cd_timeout():
	if attack_enemies.size() != 0:
		muzzle.show()
		muzzle_timer.start(0.1)
		var now_bullet = bullet.instantiate()
		now_bullet.speed = bullet_speed
		now_bullet.damage = bullet_damage
		now_bullet.position = shoot_position.global_position
		now_bullet.direction = now_bullet.position.direction_to(attack_enemies[0].global_position)
		get_tree().root.add_child(now_bullet)
	else:
		muzzle.visible = false
	
func sort_enemy():
	if attack_enemies.size() > 0:
		attack_enemies.sort_custom(
			func(x,y): 
				return x.global_position.distance_to(self.global_position) < y.global_position.distance_to(self.global_position)
		)

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy") and !attack_enemies.has(body):
		attack_enemies.append(body)
	sort_enemy()


func _on_area_2d_body_exited(body):
	if body.is_in_group("enemy") and attack_enemies.has(body):
		attack_enemies.erase(body)
	sort_enemy()

func _on_muzzle_timer_timeout():
	muzzle.hide() # Replace with function body.
