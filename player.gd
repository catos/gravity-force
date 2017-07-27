extends KinematicBody2D

var speed = 0
var acceleration = 1800
var decceleration = 3000
var target_angle = 0

# input-direction from player
var direction = Vector2()
# direction-vector multiplied by speed
var target_motion = Vector2()
# difference between target_motion and motion
var steering = Vector2()

var motion = Vector2()

const MASS = 2
const MAX_SPEED = 600

onready var Sprite = get_node("Sprite")
onready var DebugLabel = get_node("/root/Game/UI/DebugLabel")

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	var debug_text = ""
#	direction = Vector2()
	
	if Input.is_action_pressed("up"):
		direction.y = -1
#	elif Input.is_action_pressed("down"):
#		direction.y = 1
	
	if Input.is_action_pressed("left"):
		direction -= rotate_by_radians(direction, -PI/10)
#		direction.x = -1
	elif Input.is_action_pressed("right"):
		direction += rotate_by_radians(direction, PI/10)
#		direction.x = 1
	
	# No input from player
	if direction != Vector2():
		speed += acceleration * delta
	else:
		speed -= decceleration * delta
	
	speed = clamp(speed, 0, MAX_SPEED)
	target_motion = speed * direction.normalized() * delta
	steering = target_motion - motion
	
	if steering.length() > 1:
		steering = steering.normalized()
	
	motion += steering # / MASS
	
	if speed == 0:
		motion = Vector2()
	
	move(motion)
	
	if motion != Vector2():
		target_angle = atan2(motion.x, motion.y) - PI
		Sprite.set_rot(target_angle)
	
	# DEBUG
	debug_text += "direction: " + str(direction) + "\n"
	debug_text += "speed: " + str(speed) + "\n"
	debug_text += "motion: " + str(motion) + "\n"
	debug_text += "target_motion: " + str(target_motion) + "\n"
	debug_text += "target_angle: " + str(target_angle) + "\n"
	debug_text += "steering: " + str(steering) + "\n"
	DebugLabel.set_text(debug_text)

func rotate_by_radians(vector, radians):
	var ca = cos(radians)
	var sa = sin(radians)
	return Vector2(ca * vector.x - sa * vector.y, sa * vector.x + ca * vector.y)