extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#$Panel/PlayButton.connect("button_up", self, "play")
	$Panel/MakeButton.connect("button_up", self, "make")
	
func play():
	get_tree().change_scene("res://src/scenes/Play/Play.tscn")
		
func make():
	get_tree().change_scene("res://src/scenes/Make/Make.tscn")
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
