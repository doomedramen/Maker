extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const node_PlaceholderReplacer = preload("res://src/tiles/LevelItemsSheet.tscn")

onready var player = $Player
onready var player_start_position = player.position

func _process(delta):
	if player.position.y > 800:
		player.position = player_start_position
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func update_coins():
	$UI/top_right/Coin_Count.text = str(player.coin_count)
	player.coin_count
	
	


func _ready():
	var instanced = node_PlaceholderReplacer.instance()
	var tm = get_node("Items")
		
	var sizex = tm.get_cell_size().x
	var sizey = tm.get_cell_size().y
	var ts = tm.get_tileset()
	var uc = tm.get_used_cells()
	for pos in uc :
		var id = tm.get_cell(pos.x, pos.y)
		var name = ts.tile_get_name(id)
		print("swapping: ",name)
		var node = instanced.get_node(name).duplicate()
		
		var size
		if(node.region_enabled):
			size = node.region_rect.size
		else:
			size = node.get_texture().get_size()
		
		node.position = Vector2( pos.x*sizex+(0.5*size.x), pos.y*sizey+(0.5*size.y))
		add_child(node)
		tm.set_cell(pos.x, pos.y, -1) #this line remove the tile in TileMap