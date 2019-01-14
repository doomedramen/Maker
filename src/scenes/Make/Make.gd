extends Node2D

const GRID_SIZE = 64

var current_grid_position = Vector2()

var lmb_down = false

const CAMERA_MOVE_SPEED_STEP = 100

onready var Grid = preload("res://src/lib/grid.gd").new()

#var Ememy = load("res://src/sprites/Enemy.tscn")

var currentItem
var zoom_level = 1
#onready var currentItem = Ememy.instance()

func _ready():
	add_child(currentItem)
	get_tree().get_root().connect("size_changed", self, "update")
	
	#snap camera
	#$Camera2D.position = pos_to_cell($Camera2D.position)
	
func _draw():
	#draw_grid()
	Grid.draw_grid($Camera2D, self)

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

		current_grid_position = Grid.pos_to_cell(mouse_pos)
		
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