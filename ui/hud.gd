extends Control

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)

var uilife_scene = preload("res://ui/ui_life.tscn")

@onready var lives = $Lives

func init_lives(amount):
	for ul in lives.get_children():
		ul.queue_free()
	for i in amount:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)

func shield_active():
	$ShieldIndicator.visible = false

func shield_ready():
	$ShieldIndicator.texture = preload("res://assets/art/Shield2.png")
	
func shield_on_cd():
	$ShieldIndicator.visible = true
	$ShieldIndicator.texture = preload("res://assets/art/Shield_cd2.png")
func display_warning():
	$IncomingWarning.visible = true
	$WarningDuration.start()

func _on_warning_duration_timeout():
	$IncomingWarning.visible = false
