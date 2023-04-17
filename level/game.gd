extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea
@onready var asteroid_spawn_area = $PlayerSpawnPos/PlayerSpawnArea
@onready var only_once : bool = true
signal spawn_asteroids

var asteroid_scene = preload("res://level/asteroid.tscn")
var asteroid_number = 5


var score := 0:
	set(value):
		score = value
		hud.score = score
		
var lives: int:
	set(value):
		lives = value
		hud.init_lives(lives)

func _ready():
	blow_up_moon()
	game_over_screen.visible = false
	score = 0
	lives = 3
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	player.connect("shield_active", _on_shield_active)
	player.connect("shield_ready", _on_shield_ready)
	player.connect("shield_on_cd", _on_shield_on_cd)
	self.connect("spawn_asteroids", _on_spawn_asteroids)
	call_deferred("place_asteroids", asteroid_number)

func _process(_delta):
	if(asteroids.get_child_count() <= 0 && only_once):
		emit_signal("spawn_asteroids")
		only_once = false

func _on_shield_active():
	$ShieldSound.play()
	hud.shield_active()
	
func _on_shield_ready():
	$ShieldOffCdSound.play()
	hud.shield_ready()
	
func _on_shield_on_cd():
	$ShieldOnCdSound.play()
	hud.shield_on_cd()

func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)

func _on_player_died():
	lives -= 1
	player.global_position = player_spawn_pos.global_position
	if lives <= 0:
		$GameOverSound.play()
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		$PlayerDeathSound.play()
		await get_tree().create_timer(1).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(.1).timeout
		player.respawn(player_spawn_pos.global_position)

func _on_asteroid_exploded(pos, size, points):
	score += points
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				$AstroidHitSoundLarge.play()
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				$AstroidHitSoundMedium.play()
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				$AstroidHitSoundSmall.play()
				pass

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)
	return a

func place_asteroids(asteroid_count):
	var screen_size = get_viewport_rect().size
	for i in asteroid_count:
		var asteroid_placed = false
		var pos = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		var a = spawn_asteroid(pos, Asteroid.AsteroidSize.LARGE)
		while !asteroid_placed:
			if(asteroid_spawn_area.is_empty):
				asteroid_placed = true
			else:
				a.global_position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))

func _on_asteroid_delay_timeout():
	$WarningSound.stop()
	delete_children(lasers)
	asteroid_number += 5
	place_asteroids(asteroid_number)
	await get_tree().create_timer(1).timeout
	only_once = true
	
func _on_spawn_asteroids():
		$WarningSound.play()
		hud.display_warning()
		$AsteroidDelay.start()
	
func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func blow_up_moon():
	await get_tree().create_timer(1).timeout
	$Moon.visible = false
	$AnimatedSprite2D.visible = true
	$MoonExplosionSound.play()
	$AnimatedSprite2D.play()
