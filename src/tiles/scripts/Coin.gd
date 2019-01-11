extends Sprite

func _ready():
	$Area2D.connect("body_entered", self, "on_collision")
	
func on_collision(body):
	if body && body.get_name() == "Player":
		body.add_coin()
		visible = false #hide just encase queue_free takes too long
		queue_free()