extends Node2D

const GROUND_ROOT = preload("res://src/tiles/tileSheet.gd").GROUND_ROOT

static func process_tiles(tiles, style):
	
	for x in range(tiles.size()):
		for y in range(tiles[x].size()):
			var current = tiles[x][y]
			if current:
				#get tile type
				var tile_right = tiles[x+1] and tiles[x+1][y]
				var tile_left = tiles[x-1] and tiles[x-1][y]
				var tile_above = tiles[x][y-1]
				var tile_below = tiles[x][y+1]
				
				var new_name = "SliceMiddle"
				
				if !tile_above and !tile_left and tile_right and tile_below:
					new_name = "SliceTopLeft"
				if !tile_above and tile_left and !tile_right and tile_below:
					new_name = "SliceTopRight"
				if !tile_above and tile_left and tile_right and tile_below:
					new_name = "SliceTop"
				if tile_above and !tile_left and tile_right and tile_below:
					new_name = "SliceLeft"
				if tile_above and tile_left and !tile_right and tile_below:
					new_name = "SliceRight"
				if tile_above and !tile_left and tile_right and !tile_below:
					new_name = "SliceBottomLeft"
				if tile_above and tile_left and !tile_right and !tile_below:
					new_name = "SliceBottomRight"
				if tile_above and tile_left and tile_right and !tile_below:
					new_name = "SliceBottom"


				if !tile_above and !tile_left and !tile_right and !tile_below:
					new_name = "PlatformSingle"
				if !tile_above and !tile_left and tile_right and !tile_below:
					new_name = "PlatformLeft"
				if !tile_above and tile_left and tile_right and !tile_below:
					new_name = "PlatformMiddle"
				if !tile_above and tile_left and !tile_right and !tile_below:
					new_name = "PlatformRight"


				if new_name != current.type:
					current.type = new_name
			
	#return tiles