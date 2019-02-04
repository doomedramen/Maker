extends Node2D

#const Util = preload("res://src/lib/util.gd")

func _ready():
	var timer = Timer.new()
	timer.set_wait_time(2)
	timer.connect("timeout",self,"queue_free") 
	add_child(timer) #to process
	timer.start() #to start