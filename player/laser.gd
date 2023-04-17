extends Area2D

@export var speed := 500.0
@onready var lifetime = $Lifetime
var movement_vector := Vector2(0, -1) 

func _ready():
	lifetime.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

#func _on_visible_on_screen_notifier_2d_screen_exited():
	#queue_free()

func _on_area_entered(area):
	if area is Asteroid:
		var asteroid = area
		asteroid.explode()
		queue_free()


func _on_lifetime_timeout():
	queue_free()
