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
const JUMP_INPUT_NAME = "jump"
const RUN_INPUT_NAME = "sprint"
const DOWN_INPUT_NAME = "ui_down"

const dusts = []
const dusts_max_size = 4

var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false

var processed_gravty = GRAVITY_VEC
var processed_walk_speed = WALK_SPEED_RUN_MULTIPLIER

var anim=""

var coin_count = 0

var level


#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $AnimatedSprite
onready var KickupDust = load("res://src/sprites/Effects/Kickup_Dust.tscn")
onready var STARTING_POS = self.position

func _ready():
	#get parent, level?
	level = get_parent()
#	if level.get_name() != "Play":
#		print("Players parent is not 'Play'!!")
#		get_tree().quit()
		
func _physics_process(delta):
	#increment counters

	onair_time += delta

	### MOVEMENT ###
	
	# Reduce gravity when holding 'jump'
	if Input.is_action_pressed(JUMP_INPUT_NAME):
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
	var pressing_down = Input.is_action_pressed(DOWN_INPUT_NAME)
	var target_speed = 0
	
	if on_floor:
		if Input.is_action_pressed(lEFT_INPUT_NAME) and !pressing_down:
			target_speed += -1
		if Input.is_action_pressed(RIGHT_INPUT_NAME) and !pressing_down:
			target_speed +=  1
	else:
		if Input.is_action_pressed(lEFT_INPUT_NAME):
			target_speed += -1
		if Input.is_action_pressed(RIGHT_INPUT_NAME):
			target_speed +=  1

	if Input.is_action_pressed(RUN_INPUT_NAME):
		processed_walk_speed = WALK_SPEED * WALK_SPEED_RUN_MULTIPLIER
	else:
		processed_walk_speed = WALK_SPEED

	target_speed *= processed_walk_speed
	
	var lerp_rate = 0.1
	if on_floor and pressing_down:
		lerp_rate *= 0.4
	
	linear_vel.x = lerp(linear_vel.x, target_speed, lerp_rate)
	#print(linear_vel.x)

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
			new_anim = "running" if Input.is_action_pressed(RUN_INPUT_NAME) else "walking"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "running"
			new_anim = "running" if Input.is_action_pressed(RUN_INPUT_NAME) else "walking"
			
		if pressing_down && abs(linear_vel.x) == 0:
			new_anim = "ducking"
			
		if pressing_down && abs(linear_vel.x) > 0:
			new_anim = "sliding"
			
		if new_anim == "walking":
			var walk_animation_speed = abs(linear_vel.x*0.05)
			walk_animation_speed = max(walk_animation_speed, 4) #TODO not ideal, should just work
			sprite.frames.set_animation_speed("walking", walk_animation_speed)
		if new_anim == "running":
			var run_animation_speed = abs(linear_vel.x*0.016)
			run_animation_speed = max(run_animation_speed, 4) #TODO not ideal, should just work
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
			
		if pressing_down:
			new_anim = "ducking"

	if anim == "falling" && new_anim != "falling":#just landed
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
	
	
	#var collision = get_slide_collision(get_slide_count() - 1)
	#double check for floor collision
	if is_on_floor():
		dust.z_index = self.z_index+1
		dust.transform = self.transform
		dust.transform[2][1] += $CollisionShape2D.shape.extents[1]
		get_parent().add_child(dust)
		dusts.append(dust)
		
func add_coin():
	$PickupCoinSound.play()
	coin_count +=1
	level.update_coins()
	
	#TODO notify level
	
func died():
	prind('ded')
