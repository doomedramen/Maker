extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var level_json

onready var FloorSheet = preload("res://src/tiles/tileSheet.tscn").instance()
onready var Grid = preload("res://src/lib/grid.gd").new()
onready var Player = preload("res://src/sprites/Player/Player2.tscn")

func build(json):

	#set style
	FloorSheet.change_tileset_style(json.style)

	var tiles = json.tiles
	for i in range(tiles.size()):
		var current_tile = tiles[i]
		var tile_type = FloorSheet.get_node(current_tile.type)
		var tile = tile_type.duplicate()
		
		#todo add it to scene
		tile.position = Vector2(Grid.GRID_SIZE * current_tile.x, Grid.GRID_SIZE * current_tile.y)
		add_child(tile)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	$UI/Button.connect("pressed",self,"edit")
	
	level_json = SceneSwitcher.get_param("json")
	build(level_json)
	
	#TODO add player
	var player = Player.instance()
	player.position = Vector2(128,0)
	add_child(player)
	
func edit():
	SceneSwitcher.change_scene("res://src/scenes/Make/Make.tscn", {"json":level_json})