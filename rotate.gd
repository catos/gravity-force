extends KinematicBody2D

var direction = Vector2()
var mouse_position = Vector2()

var force = Vector2()
var velocity = Vector2()
var motion = Vector2()

const SLIDE_STOP_VELOCITY = 1.0
const FORCE_LENGTH = 350
const GRAVITY = 250
const DRAG = 0.01
const MAX_VELOCITY = 500

var thrusting = false

enum STATES {
	in_air,
	on_ground
}
var current_state = STATES.in_air
var just_landed = false
var landing_velocity = 0

onready var debug_label = get_node("/root/game/UI/DebugLabel")
onready var raycast_down = get_node("RayCast2D")

func _ready():
	raycast_down.add_exception(self)
	set_fixed_process(true)
	set_process_input(true)
	
func _input(event):
#	if event.type == InputEvent.MOUSE_BUTTON && event.button_index == BUTTON_LEFT && event.pressed:
#		thrusting = true
#	else: 
#		thrusting = false
#		force = Vector2(0, GRAVITY)
	pass

func _fixed_process(delta):
	var debug_text = ""
	
	# Inputs
	var fire = Input.is_action_pressed("fire") #Input.is_mouse_button_pressed(1)
	var up = Input.is_action_pressed("up")

	# Mous position and angle
	mouse_position = get_global_mouse_pos()
	direction = (mouse_position - get_pos()).normalized()
	var direction_angle = direction.angle() - deg2rad(180)
	
	# Modify force
	if up:
		force = direction * FORCE_LENGTH
	else:
		force = Vector2(0, GRAVITY)

	# Rotate to mouse position when in_air
	if current_state == STATES.in_air:
		direction_angle += direction_angle * delta * delta
		set_rot(direction_angle)

	# Calculate velocity
	velocity += force * delta
	velocity.x = clamp(velocity.x, -MAX_VELOCITY, MAX_VELOCITY)
	velocity.y = clamp(velocity.y, -MAX_VELOCITY, MAX_VELOCITY)
	
	# Set motion
	motion = velocity * delta
	motion = move(motion)
	
	# Move remainder of motion
	if is_on_ground():
		if current_state != STATES.on_ground:
			current_state = STATES.on_ground
			just_landed = true
			current_state = on_ground
			landing_velocity = velocity.y
		
		force.y = 0
		velocity.y = 0
#		revert_motion()
#		if abs(velocity.x) < SLIDE_STOP_VELOCITY:
#			revert_motion()
#		else :
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
	else:
		just_landed = false
		current_state = STATES.in_air
	
	if fire:
		print("fire")
	
	debug_text += "direction: " + str(direction.x) + ", " + str(direction.y) + "\n"
	debug_text += "motion: " + str(motion.x) + ", " + str(motion.y) + "\n"
	debug_text += "mouse_position: " + str(mouse_position.x) + ", " + str(mouse_position.y) + "\n"
	debug_text += "force: " + str(force.x) + ", " + str(force.y) + "\n"
	debug_text += "velocity: " + str(velocity.x) + ", " + str(velocity.y) + "\n"
	debug_text += "direction_angle: " + str(rad2deg(direction_angle)) + "\n"
	debug_text += "angle: " + str(rad2deg(get_rot())) + "\n"
	debug_text += "raycast_down.is_colliding(): " + str(is_on_ground()) + "\n"
	
	debug_text += "current_state: " + str(current_state) + "\n"
	debug_text += "just_landed: " + str(just_landed) + "\n"
	debug_text += "landing_velocity: " + str(landing_velocity) + "\n"
	debug_label.set_text(debug_text)
	
	update()

func _draw():
	draw_line(Vector2(), direction * 100, Color(1.0, 0.0, 0.0, 0.7), 2)

func is_on_ground():
	if raycast_down.is_colliding():
		return true
	else: 
		return false