extends Node2D

const GRID_SIZE = 64

var current_grid_position = Vector2()

var lmb_down = false

var Ememy = load("res://src/sprites/Enemy.tscn")

onready var currentItem = Ememy.instance()

func _ready():
	add_child(currentItem)
	get_tree().get_root().connect("size_changed", self, "update")

func _draw():
	var projectResolution=get_viewport().size
	var widest = projectResolution.x if projectResolution.x > projectResolution.y else projectResolution.y
	var max_lines = (widest / GRID_SIZE)+1 #avoid crash if size too smal

	for x in range(0, max_lines):
		x = x*GRID_SIZE
		draw_line(Vector2(x,0), Vector2(x, projectResolution.y), Color(1, 1, 1,.5), 1)
		draw_line(Vector2(0,x), Vector2(projectResolution.x, x), Color(1, 1, 1, .5), 1)
		
	var currentCell = Rect2(current_grid_position,Vector2(GRID_SIZE,GRID_SIZE))
	draw_rect(currentCell, Color(0, 0, 1,.3), 1)

func _input(ev):
	if ev is InputEventMouseButton and ev.button_index == BUTTON_LEFT:
		lmb_down = ev.pressed
		
		if currentItem:
			add_child(currentItem.duplicate())
		
    # Do stuff...
	if ev is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position();
		
		mouse_pos.x -=GRID_SIZE/2 #fix center bug
		mouse_pos.y -=GRID_SIZE/2 #fix center bug
		
		current_grid_position.x = round(mouse_pos.x / GRID_SIZE) * GRID_SIZE;
		current_grid_position.y = round(mouse_pos.y / GRID_SIZE) * GRID_SIZE;
		
		if currentItem:
			#get tile center
			var center_of_cell = Vector2(current_grid_position.x+(GRID_SIZE/2), current_grid_position.y+(GRID_SIZE/2))
			currentItem.position = center_of_cell
		
		if lmb_down:
			print("we draggin!")
		
		update() #rather important...