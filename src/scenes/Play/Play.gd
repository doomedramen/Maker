extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var player = $Player
onready var player_start_position = player.position

func _process(delta):
	if player.position.y > 800:
		player.position = player_start_position
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
