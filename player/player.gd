class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died
signal shield_active
signal shield_ready
signal shield_on_cd

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 250.0
@export var fire_rate := 0.15

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var shield = $Shield
@onready var shield_cd_timer = $ShieldCooldown

var laser_scene = preload("res://player/laser.tscn")

var shield_cd = false
var shoot_cd = false
var is_alive = true
var is_invincible = false

func _process(_delta):
	if !is_alive: return
	
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(fire_rate).timeout
			shoot_cd = false
			
	if Input.is_action_just_pressed("shield"):
		if shield_cd_timer.is_stopped():
			is_invincible = true
			shield.visible = true
			emit_signal("shield_active")
			await get_tree().create_timer(2).timeout
			is_invincible = false
			shield.visible = false
			emit_signal("shield_on_cd")
			shield_cd_timer.start()


func _physics_process(delta):
	if !is_alive: return
	
	var input_vector := Vector2(0, Input.get_axis("move_forward", "move_backward"))
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed*delta))
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed*delta))

	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 2)

	move_and_slide()

	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

func shoot_laser():
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("laser_shot", l)

func die():
	if (is_alive==true && !is_invincible):
		is_alive = false
		sprite.visible = false
		cshape.set_deferred("disabled", true)
		emit_signal("died")

func respawn(pos):
	if is_alive == false:
		is_alive = true
		global_position = pos
		velocity = Vector2.ZERO
		sprite.visible = true
		cshape.set_deferred("disabled", false)

func _on_shield_cooldown_timeout():
	emit_signal("shield_ready")
