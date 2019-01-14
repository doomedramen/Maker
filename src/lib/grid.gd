const GRID_SIZE = 64

func draw_grid(camera, scene):
	#var projectResolution=OS.get_real_window_size()#get_viewport().size
	var projectResolution = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	var widest = projectResolution.x if projectResolution.x > projectResolution.y else projectResolution.y

	var zoom = camera.zoom #should be same as y
	
	var max_lines = (widest / GRID_SIZE)*3 #avoid crash if size too smal
	
	var start = camera.position
	var end = Vector2(start.x+projectResolution.x * zoom.x, start.y+projectResolution.y * zoom.y)

	start.x -= GRID_SIZE
	start.y -= GRID_SIZE
	end.x += GRID_SIZE
	end.y += GRID_SIZE
		
	var startCell = pos_to_cell(start)
	var endCell = pos_to_cell(end)
	
	for i in range(0, max_lines):
		i = GRID_SIZE*i
		
		scene.draw_line(Vector2(startCell.x,startCell.y+i), Vector2(endCell.x, startCell.y+i), Color(1, 1, 1,.5), 1)
		scene.draw_line(Vector2(startCell.x+i,startCell.y), Vector2(startCell.x+i, endCell.y), Color(1, 1, 1,.5), 1)
		

func pos_to_cell(vec2):
	var out = Vector2();
	out.x = round(vec2.x / GRID_SIZE) * GRID_SIZE;
	out.y = round(vec2.y / GRID_SIZE) * GRID_SIZE;
	return out