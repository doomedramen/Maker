extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 3500)
const GRAVITY_JUMP_MULTIPLIER = 0.6
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 500 # pixels/sec
const WALK_SPEED_RUN_MULTIPLIER = 1.8
const JUMP_SPEED = 1000
const EXTRA_JUMP_SPEED_FROM_RUN = 0.1
const SIDING_CHANGE_SPEED = 10



const lEFT_INPUT_NAME = "ui_left"
const RIGHT_INPUT_NAME = "ui_right"
const JUMP_INPUT_NAME = "ui_up"
const RUN_INPUT_NAME = "sprint"

var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false

var processed_gravty = GRAVITY_VEC
var processed_walk_speed = WALK_SPEED_RUN_MULTIPLIER

var anim=""

const dusts = []
const dusts_max_size = 4

#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $AnimatedSprite
onready var KickupDust = load("res://src/sprites/Kickup_Dust.tscn")

onready var STARTING_POS = self.position

func _physics_process(delta):
	#increment counters

	onair_time += delta

	### MOVEMENT ###
	
	# Reduce gravity when holding 'jump'
	if Input.is_action_pressed("ui_up"):
		processed_gravty = GRAVITY_VEC*GRAVITY_JUMP_MULTIPLIER
	else:
		processed_gravty = GRAVITY_VEC
	
	# Apply Gravity
	linear_vel += delta * processed_gravty
	# Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect Floor
	if is_on_floor():
		onair_time = 0

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###

	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed(lEFT_INPUT_NAME):
		target_speed += -1
	if Input.is_action_pressed(RIGHT_INPUT_NAME):
		target_speed +=  1

	if Input.is_action_pressed(RUN_INPUT_NAME):
		processed_walk_speed = WALK_SPEED * WALK_SPEED_RUN_MULTIPLIER
	else:
		processed_walk_speed = WALK_SPEED

	target_speed *= processed_walk_speed
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)
	print(linear_vel.x)

	# Jumping
	if on_floor and Input.is_action_just_pressed(JUMP_INPUT_NAME):
		linear_vel.y = -JUMP_SPEED
		
		#TODO run speed should add to how high you jump
		linear_vel.y -= abs(linear_vel.x*EXTRA_JUMP_SPEED_FROM_RUN)
		#$sound_jump.play()


	### ANIMATION ###

	var new_anim = "idle"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "running"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "running"
			
		if new_anim == "running":
			#set animation speed
			var run_animation_speed = abs(linear_vel.x*0.02)
			run_animation_speed = max(run_animation_speed, 6) #TODO not ideal, should just work
			
			sprite.frames.set_animation_speed("running", run_animation_speed)
	else:
	
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed(lEFT_INPUT_NAME) and not Input.is_action_pressed(RIGHT_INPUT_NAME):
			sprite.scale.x = -1
		if Input.is_action_pressed(RIGHT_INPUT_NAME) and not Input.is_action_pressed(lEFT_INPUT_NAME):
			sprite.scale.x = 1

		if linear_vel.y < 0:
			new_anim = "jumping"
		else:
			new_anim = "falling"

	if anim == "falling" && new_anim != "falling":
		#just landed
		create_floor_dust()

	if new_anim != anim:
		anim = new_anim
		sprite.play(anim)
		
func create_floor_dust():
	#limt them!
	if dusts.size() >= dusts_max_size:
		dusts[0].queue_free()
		dusts.remove(0)


	var dust = KickupDust.instance()
	dust.get_node("Particles2D").restart()
	
	var collision = get_slide_collision(0)
	#double check for floor collision
	if collision:
	

#		var tile_id = collision.collider.get_cellv(collision.collider.world_to_map(collision.position))
#		if tile_id != null && tile_id > -1:
#			var tile_set = collision.collider.tile_set
#			var tile_stream_texture = tile_set.tile_get_texture(tile_id)
#			var tile_texture = tile_stream_texture.get_data()
#			tile_texture.lock()
#			var tile_region = tile_set.tile_get_region(tile_id)
#			print(tile_region)
#			var random_pixel = tile_texture.get_pixel(int(rand_range(tile_region.position[0], tile_region.end[0])),tile_region.position[0])
#			tile_texture.unlock()
#			dust.set_modulate(random_pixel)

		dust.z_index = self.z_index+1
		dust.transform = self.transform
		dust.transform[2][1] += $CollisionShape2D.shape.extents[1]
		get_parent().add_child(dust)
		dusts.append(dust)
