extends KinematicBody2D

const UP = Vector2(0,-1)
const MAX_VELOCITY = Vector2(300, 40)
const ACCELERATION = Vector2(40, 4)
const G = 20
const INIT_VEL = 250
const JMP_HEIGHT = 460

var motion = Vector2()
var velocity = Vector2()
var friction = false
var bounce_count = 3
var bouncing = false
var was_in_air = -1
#var collision

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):

	motion.y += G
	
	if is_on_floor():
		if bouncing:
			was_in_air += 1
			bounce()
		if Input.is_action_pressed("ui_space"):
			motion.y = -JMP_HEIGHT
		if friction:
			motion.x = lerp(motion.x, 0, 0.3)
	else:
		was_in_air = 0
		motion.x = lerp(motion.x, 0, 0.05)
		bouncing = true
	
	movement_handler()
	
	velocity = move_and_slide(motion,UP)
	
func bounce():
	if(bounce_count > 0):
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			bounce_count -= 1
			bouncing = true
			motion = motion.bounce(collision.normal)
			print("bounce_count: ", collision.normal)
	else: 
		bouncing = false
	
func movement_handler():
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
#		deaccelerate()
		friction = true
	else:
		motion.x = 0
	pass
	
#func deaccelerate():
#	if Input.is_action_just_released("ui_left") or deacc_left: # deaccelaration left
#		deacc_left = true
#		motion.x = min(velocity.x+ACCELERATION.x, 0)	
#	elif Input.is_action_just_released("ui_right") or deacc_right: # deaccelaration right
#		deacc_right = true
#		motion.x = max(velocity.x-ACCELERATION.x, 0)

