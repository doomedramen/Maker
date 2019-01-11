extends Node2D

const GRID_SIZE = 64

var current_grid_position = Vector2()

var lmb_down = false

const CAMERA_MOVE_SPEED_STEP = 100

#var Ememy = load("res://src/sprites/Enemy.tscn")

var currentItem
var zoom_level = 1
#onready var currentItem = Ememy.instance()

func _ready():
	add_child(currentItem)
	get_tree().get_root().connect("size_changed", self, "update")
	
	#snap camera
	#$Camera2D.position = pos_to_cell($Camera2D.position)

func pos_to_cell(vec2):
	var out = Vector2();
	out.x = round(vec2.x / GRID_SIZE) * GRID_SIZE;
	out.y = round(vec2.y / GRID_SIZE) * GRID_SIZE;
	return out
	
func draw_grid():
	#var projectResolution=OS.get_real_window_size()#get_viewport().size
	var projectResolution = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	
	var widest = projectResolution.x if projectResolution.x > projectResolution.y else projectResolution.y

	var zoom = $Camera2D.zoom #should be same as y
	
	print(projectResolution)
	
	var max_lines = (widest / GRID_SIZE)*3 #avoid crash if size too smal
	
	var start = $Camera2D.position
	var end = Vector2(start.x+projectResolution.x * zoom.x, start.y+projectResolution.y * zoom.y)

	start.x -= GRID_SIZE
	start.y -= GRID_SIZE
	end.x += GRID_SIZE
	end.y += GRID_SIZE
		
	var startCell = pos_to_cell(start)
	var endCell = pos_to_cell(end)
	
	for i in range(0, max_lines):
		i = GRID_SIZE*i
		
		draw_line(Vector2(startCell.x,startCell.y+i), Vector2(endCell.x, startCell.y+i), Color(1, 1, 1,.5), 1)
		draw_line(Vector2(startCell.x+i,startCell.y), Vector2(startCell.x+i, endCell.y), Color(1, 1, 1,.5), 1)
		

func _draw():
	draw_grid()

	var currentCell = Rect2(current_grid_position,Vector2(GRID_SIZE,GRID_SIZE))
	draw_rect(currentCell, Color(0, 0, 1,.3), 1)

func _input(ev):
	if ev is InputEventMouseButton and ev.button_index == BUTTON_LEFT:
		lmb_down = ev.pressed
		
		if currentItem:
			add_child(currentItem.duplicate())
		
	if ev is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position();
		mouse_pos -= Vector2(GRID_SIZE/2, GRID_SIZE/2)

		#TODO only bother with grid position if not over UI

		current_grid_position = pos_to_cell(mouse_pos)
		
		#if currentItem:
		#	var center_of_cell = Vector2(current_grid_position.x+(GRID_SIZE/2), current_grid_position.y+(GRID_SIZE/2))
		#	currentItem.position = center_of_cell
		
		if lmb_down:
			print("we draggin!")
			
		
	if ev is InputEventKey:
		if Input.is_action_pressed("ui_left"):
			$Camera2D.position.x -=CAMERA_MOVE_SPEED_STEP
		if Input.is_action_pressed("ui_right"):
			$Camera2D.position.x +=CAMERA_MOVE_SPEED_STEP
		if Input.is_action_pressed("ui_up"):
			$Camera2D.position.y -=CAMERA_MOVE_SPEED_STEP
		if Input.is_action_pressed("ui_down"):
			$Camera2D.position.y +=CAMERA_MOVE_SPEED_STEP
		
	
	
	update() #rather important...