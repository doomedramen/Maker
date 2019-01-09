extends Node2D

const GRID_SIZE = 64

var current_grid_position = Vector2()

var lmb_pressed = false

func _ready():
	pass

func _draw():

	var max_lines = 100; #avoid crash if size too smal

	for x in range(0, max_lines):
		x = x*GRID_SIZE
		draw_line(Vector2(x,0), Vector2(x, 1000), Color(1, 1, 1,.5), 1)
		draw_line(Vector2(0,x), Vector2(1000, x), Color(1, 1, 1, .5), 1)
		
	var currentCell = Rect2(current_grid_position,Vector2(GRID_SIZE,GRID_SIZE))
	draw_rect(currentCell, Color(0, 0, 1,.3), 1)


func _input(ev):
	if ev is InputEventMouseButton and ev.button_index == BUTTON_LEFT:
		lmb_pressed = ev.pressed
    # Do stuff...
	if ev is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position();
			
		mouse_pos.x -=GRID_SIZE/2 #fix center bug
		mouse_pos.y -=GRID_SIZE/2 #fix center bug
		
		current_grid_position.x = round(mouse_pos.x / GRID_SIZE) * GRID_SIZE;
		current_grid_position.y = round(mouse_pos.y / GRID_SIZE) * GRID_SIZE;
		
		if lmb_pressed:
			print("we draggin!")
		
		update() #rather important...