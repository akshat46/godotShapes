extends KinematicBody2D

const UP = Vector2(0,-1)
const MAX_VELOCITY = Vector2(300, 40)
const ACCELERATION = Vector2(40, 4)
const G = 20
const INIT_VEL = 250
const JMP_HEIGHT = 440
const BOUNCE_COUNT = 2 # minimum bounce count
const WALL_BOUNCE = 1 # amx wall bounce/jump count

var motion = Vector2() # set movement to this vector
var velocity = Vector2() # current movement in this vector
var friction = false
var in_air = false # check if ball is in air or not
var bounce_count = BOUNCE_COUNT 
var velocity_y_temp = 0 # height the object is falling from
var cancel_bounce = false # pressing down to cancel bounce // TODO: replace with hold to bounce
var wall_bounce_count = WALL_BOUNCE # max number of wall jumps allowed
var is_on_floor = false # so that is_on_floor() isnt called multiple times

func _ready():
	pass # Replace with function body.

# TODO: implement state machine
# states: idle, moving (with move direction variable), in air, 
func _physics_process(delta):
	init_floor()
	_apply_friction()
	_bounce_handler()
	_wall_bounce_handler()
	_movement_handler()
	velocity = move_and_slide(motion,UP)

func init_floor():
	if is_on_floor():
		is_on_floor = true
	else: # in air
		is_on_floor = false
		motion.y += G

func _apply_friction():
	if is_on_floor and friction:
		motion.x = lerp(motion.x, 0, 0.3)
	elif !is_on_floor:
		motion.x = lerp(motion.x, 0, 0.05)

func _wall_bounce_handler():
	if is_on_floor:
		wall_bounce_count = WALL_BOUNCE
	if(is_on_wall() and wall_bounce_count>0):
		if Input.is_action_pressed("ui_space"):
			wall_bounce_count -= 1
			motion.y = -JMP_HEIGHT*0.8
	
func _bounce_handler():
	_cancel_bounce()
	if is_on_floor:
		if in_air and !cancel_bounce:
			bounce()
		else:
			bounce_count = BOUNCE_COUNT
			cancel_bounce = false
			in_air = false
	else:
		if !cancel_bounce:
			in_air = true
			velocity_y_temp = velocity.y # has last speed right before bounce() called
			if(velocity_y_temp>BOUNCE_COUNT*100):
				bounce_count = int(round(velocity_y_temp/100))
		else:
			in_air = false

func _cancel_bounce():
	if Input.is_action_pressed("ui_down"):
		cancel_bounce = true
	pass
	
func bounce():
	if bounce_count>0:
		motion.y = -velocity_y_temp*0.8
		bounce_count -= 1
	else:
		in_air = false

func _movement_handler():
	if Input.is_action_just_pressed("ui_space") and is_on_floor:
		motion.y = -JMP_HEIGHT
	
	if Input.is_action_pressed("ui_right"):
		if (velocity.x == 0):
			motion.x = INIT_VEL
		else: # acceleration right
			motion.x = min(velocity.x+ACCELERATION.x, MAX_VELOCITY.x)
		
	elif Input.is_action_pressed("ui_left"):
		if (velocity.x == 0):
			motion.x = -INIT_VEL
		else: # acceleration left
			motion.x = max(velocity.x-ACCELERATION.x, -MAX_VELOCITY.x)
		
	elif velocity.x != 0:
		friction = true
	
	else:
		motion.x = 0
	pass

