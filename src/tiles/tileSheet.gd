extends Node

const GROUND_ROOT = "res://assets/tiles/Ground"
var STYLES = {
'GRASS':'Grass',
'DIRT':'Dirt',
'PLANET':'Planet',
'SAND':'Sand',
'SNOW':'Snow',
'STONE':'Stone'
}

var current_style = STYLES.GRASS

func change_tileset_style(style):
	current_style = style
	for i in range(0, get_child_count()):
		var sprite = get_child(i)
		change_sprite_style(sprite, style)
			
func change_sprite_style(sprite, style):
		var current_texture_file = sprite.texture.get_path().split('/')[-1]
		var new_texture_path = GROUND_ROOT + '/' + style + '/' + current_texture_file
		var tex = load(new_texture_path)
		sprite.set_texture(tex)