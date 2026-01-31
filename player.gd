extends CharacterBody2D

@export var speed := 300.0
@export var jump_velocity := -600.0
@export var gravity := 1200.0
@export var wall_slide_speed := 80.0
@export var wall_jump_force := Vector2(-300, -800)
@export var max_fall_velocity := 1000
@export var dash_time := 0.15
@export var dash_velocity := 1500

@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12
@export var wall_jump_lock_time := 0.15
@export var jump_cut_multiplier := 0.4

enum State { Idle, Walk, Jump, WallSlide, WallJump }
var current_state: State = State.Idle

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var wall_jump_lock_timer := 0.0
var dash_timer
var last_on_ground_time := 0.0
var last_on_wall_time := 0.0
var last_on_wall_right_time := 0.0
var last_on_wall_left_time := 0.0

var is_dashing := false
var dash_direction

var isFacingRight := true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	
	update_timers(delta)
	apply_gravity(delta)
	handle_horizontal()
	handle_wall_slide(delta)
	handle_jump()
	handle_dash()
	update_state()

	move_and_slide()
	animate()
	
	wall_jump_lock_timer -= delta


func update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta


func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta


func handle_horizontal() -> void:
	if wall_jump_lock_timer > 0.0:
		return
		
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = direction < 0
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed)
		else:
			velocity.x = 0


func handle_jump() -> void:
	if is_on_wall_only() and Input.is_action_just_pressed("jump"):
		var wall_dir = get_wall_direction()
		velocity.x = wall_jump_force.x * wall_dir
		velocity.y = wall_jump_force.y
		wall_jump_lock_timer = wall_jump_lock_time
		return

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier
	
	velocity.y = min(velocity.y, max_fall_velocity)
	
func handle_dash() -> void:
	if is_dashing:
		velocity.y = 0
		dash_timer -= get_physics_process_delta_time()
		velocity.x = dash_velocity * dash_direction
		if dash_timer <= 0.0:
			is_dashing = false
		return
		
	if Input.is_action_just_pressed("dash"):
		velocity.y = 0
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x = dash_velocity * direction
		is_dashing = true
		dash_timer = dash_time
		dash_direction = direction
		
func handle_wall_slide(delta: float) -> void:
	if !is_on_wall_only():
		return

	var wall_dir = get_wall_direction()
	var input_dir = Input.get_axis("move_left", "move_right")

	sprite.flip_h = wall_dir > 0
	if input_dir == wall_dir:
		velocity.y = min(velocity.y + gravity * delta, wall_slide_speed)


func update_state() -> void:
	if is_on_wall_only() and abs(velocity.y) > 0:
		current_state = State.WallSlide
	elif !is_on_floor():
		current_state = State.Jump
	elif abs(velocity.x) > 1.0:
		current_state = State.Walk
	else:
		current_state = State.Idle


func animate() -> void:
	match current_state:
		State.Idle:
			sprite.play("idle")
		State.Walk:
			sprite.play("walk")
		State.Jump:
			sprite.play("jump")
			sprite.frame = 3
		State.WallSlide:
			sprite.play("wall_slide")

func get_wall_direction() -> int:
	var wall_normal = get_wall_normal()
	return -sign(wall_normal.x)
