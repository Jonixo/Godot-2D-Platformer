extends CharacterBody2D


const SPEED = 175
const JUMP_VELOCITY = -450
const GRAVITY = 1800

const DASH_SPEED = 500

@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@export var coyote_time : float = .1
@export var jump_buffer_timer : float = .1

@onready var dash_timeout = $DashTimeout
@onready var dash_timer = $DashTimer
@onready var coyote_timer = $CoyoteTimer
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var jump_available: bool = true
var jump_buffer: bool = false
var dashing: bool = false
var can_dash: bool = true

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	GameManager.player = self
	GameManager.playerOriginalPos = position
	
	
func jump():
	velocity.y = jump_velocity
	jump_available = false

func coyote_timeout():
	jump_available = false

func movement(delta):
	if not is_on_floor():
		if jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start(coyote_time)
				#get_tree().create_timer(coyote_time).timeout.connect(coyote_timeout)
		
		if  velocity.y > 0.0:
			velocity.y += jump_gravity * delta
		else:
			velocity.y += jump_gravity * delta
			fall_gravity
	else:
		jump_available = true
		coyote_timer.stop()
		if jump_buffer:
			jump()
			jump_buffer = false
		
	if Input.is_action_just_pressed("Jump"):
		if jump_available:
			jump()
		else:
			jump_buffer = true
			get_tree().create_timer(jump_buffer_timer).timeout.connect(on_jump_buffer_timeout)
		
	var direction = Input.get_axis("Left","Right")
	if Input.is_action_just_pressed("dashing") and can_dash: 
		dashing = true
		dash_timer.start()
		dash_timeout.start()
		can_dash = false
	
	if direction != 0:

		if not dashing:
			velocity.x = direction * SPEED
		else:
			velocity.x = direction * DASH_SPEED
	else:
		velocity.x = 0
		
	if Input.is_action_just_pressed("Down") and is_on_floor():
		position.y += 3
		

	move_and_slide()
	
func updateAnimation():
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
	if is_on_floor():
		if abs(velocity.x) >= 0.1:
			animated_sprite_2d.play("Run")
		else:
			animated_sprite_2d.play("Idle")
	else:
		animated_sprite_2d.play("Jump")
		
	
func on_jump_buffer_timeout() -> void:
	jump_buffer = false
	
func on_dashing_timeout() -> void:
	dashing = false
	
func _on_dash_timeout_timeout():
	can_dash = true	
	 
func _process(delta):
	updateAnimation()

func _physics_process(delta):
	movement(delta)
