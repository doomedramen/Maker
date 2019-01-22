extends Node2D

const CAMERA_MOVE_SPEED_STEP = 100
const MAP_SIZE = Vector2(64, 32)
const LEVEL_TILES = Array()
const LEVEL_ITEMS = Array()

const CAMERA_PADDING = Vector2(256,256)
const RECT_COLOR = Color(0, 0, 1,.2)

var snapped_position = Vector2()
var cell_position = Vector2()
var lmb_down = false
var rmb_down = false

var player_position


onready var FloorSheet = preload("res://src/tiles/tileSheet.tscn").instance()
onready var Grid = preload("res://src/lib/grid.gd").new()
onready var Player = preload("res://src/sprites/Player/Player2.tscn")
onready var currentSelection

var TILES_PARENT
var ITEMS_PARENT

func _ready():
	var existing_level = SceneSwitcher.get_param("json")
	initTiles(existing_level)
	initCamera()
	force_camera_fix()
	
	$UI/RunButton.connect("pressed",self,"make_json")
	$UI/TopPanel/Tabs/Blocks/GroundButton.connect("pressed",self,"current_item_earth")

	init_style_list()
	


func init_style_list():
	var item_list = $UI/ItemList

	for ItemID in range(FloorSheet.STYLES.size()):
		item_list.add_item(FloorSheet.STYLES.values()[ItemID],null,true)
	
	item_list.select(0 ,true) #This sets a default so we don't have
    # to do error catching if an empty selection is captured.
	#get_node("GoButton").connect("pressed",self,"ReportListItem")
	item_list.connect("item_selected", self,"style_selected")
	
func style_selected(index):
	var style = FloorSheet.STYLES.values()[index]
	
	#change tileset (future tiles)
	FloorSheet.change_tileset_style(style)
	
	#change all existing tiles
	for i in range(0, $TILES.get_child_count()):
		var sprite = $TILES.get_child(i)
		FloorSheet.change_sprite_style(sprite, style)

func current_item_earth():
	currentSelection = FloorSheet.get_node("GrassCenter")
	
func change_style():
		pass

func force_camera_fix():
	if $Camera2D.position.x < $Camera2D.limit_left:
		$Camera2D.position.x = $Camera2D.limit_left
	if $Camera2D.position.x > $Camera2D.limit_right-(Global.ScreenSize.x*$Camera2D.zoom.x):
		$Camera2D.position.x = $Camera2D.limit_right-(Global.ScreenSize.x*$Camera2D.zoom.x)
	if $Camera2D.position.y < $Camera2D.limit_top:
		$Camera2D.position.y = $Camera2D.limit_top
	if $Camera2D.position.y > $Camera2D.limit_bottom-(Global.ScreenSize.y*$Camera2D.zoom.y):
		$Camera2D.position.y = $Camera2D.limit_bottom-(Global.ScreenSize.y*$Camera2D.zoom.y)

func initCamera():
	$Camera2D.limit_left = -CAMERA_PADDING.x
	$Camera2D.limit_top = -CAMERA_PADDING.y
	$Camera2D.limit_right = (MAP_SIZE.x*Grid.GRID_SIZE)+CAMERA_PADDING.x
	$Camera2D.limit_bottom = (MAP_SIZE.y*Grid.GRID_SIZE)+CAMERA_PADDING.y

func initTiles(json):
	#add a place to put tiles
	TILES_PARENT = $TILES
	ITEMS_PARENT = $ITEMS
	

	#init empty array(s)
	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.x):
			if(y == 0):	#add new y array
				LEVEL_TILES.insert(x,Array())
				LEVEL_ITEMS.insert(x,Array())
			LEVEL_TILES[x].insert(y,null)
			LEVEL_ITEMS[x].insert(y,null)
			
	if json:
		var tiles = json.tiles
		var items = json.items
		
		#load style
		FloorSheet.change_tileset_style(json.style)
		
		#items
		for i in range(items.size()):
			var current_item = items[i]
			LEVEL_ITEMS[current_item.x][current_item.y] = current_item
			var item_type = FloorSheet.get_node(current_item.type)
			var item = item_type.duplicate()
			ITEMS_PARENT.add_child(item)
			item.position = Vector2(Grid.GRID_SIZE * current_item.x + (Grid.GRID_SIZE/2), Grid.GRID_SIZE * current_item.y + (Grid.GRID_SIZE/2))
			item.name = process_name(current_item['name'])
		
		#times
		for i in range(tiles.size()):
			var current_tile = tiles[i]
			LEVEL_TILES[current_tile.x][current_tile.y] = current_tile
			var tile_type = FloorSheet.get_node(current_tile.type)
			var tile = tile_type.duplicate()
			TILES_PARENT.add_child(tile)
			tile.position = Vector2(Grid.GRID_SIZE * current_tile.x + (Grid.GRID_SIZE/2), Grid.GRID_SIZE * current_tile.y + (Grid.GRID_SIZE/2))
			tile.name = process_name(current_tile['name'])

func in_grid_range():
	return cell_position.x >= 0 and cell_position.y >= 0 and cell_position.x < MAP_SIZE.x and cell_position.y < MAP_SIZE.y

func process_name(name):
	return name.replace('@','')

func place_tile():

	if in_grid_range():
		if currentSelection:
			var current_cell_value = LEVEL_TILES[cell_position.x][cell_position.y]
			if current_cell_value:
				remove_tile()#empty it
				
			var newItem = currentSelection.duplicate()
					
			#DELETE EVERYTHING EXCEPT THE SPRITE (delete collision stuff)
			for i in range(0, newItem.get_child_count()):
	    		newItem.get_child(i).queue_free()
			TILES_PARENT.add_child(newItem)
			newItem.name = process_name(newItem.name)
			
			#LEVEL_TILES[cell_position.x][cell_position.y] = newItem.name #update cell value
			LEVEL_TILES[cell_position.x][cell_position.y] = {'name':newItem.name, 'type':currentSelection.name} #update cell value

func remove_tile():
	if in_grid_range():
		var current_cell_value = LEVEL_TILES[cell_position.x][cell_position.y]
		if current_cell_value != null:
			#print("culling ",current_cell_value['name'])
			var node_to_remove = TILES_PARENT.find_node(current_cell_value['name'], false, false)
			node_to_remove.queue_free()
			LEVEL_TILES[cell_position.x][cell_position.y] = null

func _draw():
	Grid.draw_grid_v2($Camera2D, MAP_SIZE,self)

	var currentCell = Rect2(snapped_position,Vector2(Grid.GRID_SIZE,Grid.GRID_SIZE))
	draw_rect(currentCell, RECT_COLOR, 1)

func over_ui():
	var mouse_pos = get_global_mouse_position()
	var top_bar_rect = Rect2($Camera2D.position+$UI/TopPanel.rect_position, $UI/TopPanel.rect_size)
	return top_bar_rect.has_point(mouse_pos)
	
func _input(ev):

	var over_UI = over_ui()

	if ev is InputEventMouseButton and !over_UI:
	
		if ev.button_index == BUTTON_LEFT:
			if !lmb_down and ev.pressed: #lmb just went down for the first time
				place_tile()
			lmb_down = ev.pressed
		if ev.button_index == BUTTON_RIGHT:
			if !rmb_down and ev.pressed: #rmb just went down for the first time
				remove_tile()
			rmb_down = ev.pressed
			
	if ev is InputEventMouseMotion and !over_UI:
		var mouse_pos = get_global_mouse_position();
		mouse_pos -= Vector2(Grid.GRID_SIZE/2, Grid.GRID_SIZE/2)

		#TODO only bother with grid position if not over UI
		snapped_position = Grid.pos_to_snap(mouse_pos)
		cell_position = Grid.pos_to_cell(mouse_pos)
		
		if currentSelection:
			var center_of_cell = Vector2(snapped_position.x+(Grid.GRID_SIZE/2), snapped_position.y+(Grid.GRID_SIZE/2))
			currentSelection.position = center_of_cell
		
		#TODO fix this
		if lmb_down:
			place_tile()	
		if rmb_down:
			remove_tile()
		
	if ev is InputEventKey:
		if Input.is_action_pressed("ui_left"):
			$Camera2D.position.x -=CAMERA_MOVE_SPEED_STEP
		if Input.is_action_pressed("ui_right"):
			$Camera2D.position.x += CAMERA_MOVE_SPEED_STEP
		if Input.is_action_pressed("ui_up"):
			$Camera2D.position.y -= CAMERA_MOVE_SPEED_STEP
		if Input.is_action_pressed("ui_down"):
			$Camera2D.position.y += CAMERA_MOVE_SPEED_STEP
				
		force_camera_fix()
	
	
	update() #rather important...
	
	
func make_json():
	var my_json = {'tiles':[], 'items':[], 'style':FloorSheet.current_style}
	
	#if !player_position:
	#		Global.alert("You have not placed a player start position.")
	#		return
	
	#items
	for x in range(LEVEL_ITEMS.size()):
		for y in range(LEVEL_ITEMS[x].size()):
			var current = LEVEL_ITEMS[x][y]
			if current:
				var j = {'name':current['name'],'type':current['type'], 'x':x, 'y':y};
				my_json['items'].append(j)
	
	#tiles
	for x in range(LEVEL_TILES.size()):
		for y in range(LEVEL_TILES[x].size()):
			var current = LEVEL_TILES[x][y]
			if current:
				var j = {'name':current['name'],'type':current['type'], 'x':x, 'y':y};
				my_json['tiles'].append(j)
	SceneSwitcher.change_scene("res://src/scenes/Play/Run.tscn", {"json":my_json})
	