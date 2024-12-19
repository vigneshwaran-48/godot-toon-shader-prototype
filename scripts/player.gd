class_name Player
extends CharacterBody3D

@export var animation_tree: AnimationTree
@export var sensitivity_horizontal = 0.5
@export var sensitivity_vertical = 0.2
@export var walk_speed = 2.0
@export var run_speed = 5.0

@onready var camera_pivot: Node3D = $camera_pivot
@onready var model: Node3D = $visuals

const JUMP_VELOCITY = 4.5

var speed = 2.0
var is_running = false
var basic_anim = 0.0
var is_aiming = false
var is_falling = false
var is_interacting: bool = false

func _ready() -> void:
	# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		rotate_y(-deg_to_rad(event.relative.x * sensitivity_horizontal))
		camera_pivot.rotate_x(deg_to_rad(event.relative.y * sensitivity_vertical))
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-45), deg_to_rad(45))
		
		if !is_aiming:
			# Making the model rotate in the opposite direction. So, the model looks like not rotating.
			model.rotate_y(deg_to_rad(event.relative.x * sensitivity_horizontal))
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if !is_interacting && Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2.ZERO if is_interacting else Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	is_running = Input.is_action_pressed("run")
	is_aiming = Input.is_action_pressed("aim")
	
	is_falling = !is_on_floor()
	
	if is_running:
		speed = run_speed
	else:
		speed = walk_speed
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		if !is_aiming:
			model.look_at(lerp(position, position + direction, 0.1))
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
		
	if is_on_floor():
					
		var target_anim = 1.0 if input_dir != Vector2.ZERO else 0.0
		target_anim = target_anim * 2.0 if is_running else target_anim * 1
		basic_anim = lerpf(basic_anim, target_anim, 0.1)
		animation_tree.set("parameters/basic_movement/blend_position", basic_anim)
			
		# Strafe animations
		var animX = input_dir.x * 2 if is_running else input_dir.x
		var animY = input_dir.y * 2 if is_running else input_dir.y
			 
		animation_tree.set("parameters/aim_movement/blend_position", Vector2(animX, animY))		

	move_and_slide()

func notify_interactable(interactable: Interactable) -> void:
	pass
