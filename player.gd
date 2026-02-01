extends CharacterBody2D

@export var speed := 1500.0
@export var jump_velocity := -3000.0
@export var gravity := 6000.0
@export var wall_slide_speed := 400.0
@export var wall_jump_force := Vector2(-1500, -4000)
@export var max_fall_velocity := 5000
@export var dash_time := 0.15
@export var dash_velocity := 7500

@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12
@export var wall_jump_lock_time := 0.15
@export var jump_cut_multiplier := 0.4
@export var dash_horizontal_disable_time = 0.15
@export var walk_sound_time = 0.5

@export var start_respawn_position: Vector2 = Vector2(584, -1912)
var respawn_position: Vector2 = start_respawn_position

enum State { Idle, Walk, Jump, WallSlide, Dash }
var current_state: State = State.Idle

var is_past := false
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var wall_jump_lock_timer := 0.0
var dash_horizontal_disable_timer := 0.0
var dash_timer
var last_on_ground_time := 0.0
var last_on_wall_time := 0.0
var last_on_wall_right_time := 0.0
var last_on_wall_left_time := 0.0
var walk_sound_timer := 0.0


var is_dashing := false
var has_dashed_midair := false
var dash_direction

var is_facing_right := true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound = $JumpPlayer
@onready var walk_sound = $walkPlayer


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
	
	check_death()
	
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
	
	dash_horizontal_disable_timer -= delta
	walk_sound_timer-=delta
	


func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
	else:
		has_dashed_midair = false


func handle_horizontal() -> void:
	if wall_jump_lock_timer > 0.0:
		return
		
	if dash_horizontal_disable_timer > 0:
		return
		
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = direction < 0
		is_facing_right = true if direction > 0 else false
		if is_on_floor():
			if walk_sound_timer<= 0 :
				walk_sound.play()
				walk_sound_timer= walk_sound_time
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed)
		else:
			velocity.x = 0


func handle_jump() -> void:
	if is_on_wall_only() and Input.is_action_just_pressed("jump"):
		jump_sound.play()
		var wall_dir = get_wall_direction()
		velocity.x = wall_jump_force.x * wall_dir
		velocity.y = wall_jump_force.y
		wall_jump_lock_timer = wall_jump_lock_time
		return

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		jump_sound.play()
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
		velocity.x = dash_velocity * (1.0 if is_facing_right else -1.0) 
		if dash_timer <= 0.0:
			is_dashing = false			
			
		if is_on_wall_only():
			velocity.x = 0
			is_dashing = false
		 
			
		return
		
	if Input.is_action_just_pressed("dash"):
		if has_dashed_midair:
			return
		velocity.y = 0
		var direction = (1.0 if is_facing_right else -1.0)
		velocity.x = dash_velocity * direction
		is_dashing = true
		dash_timer = dash_time
		
		dash_horizontal_disable_timer = dash_horizontal_disable_time
			
		if not is_on_floor():
			has_dashed_midair = true
			
		
func handle_wall_slide(delta: float) -> void:
	if !is_on_wall_only():
		return
	
	has_dashed_midair = false

	var wall_dir = get_wall_direction()
	var input_dir = Input.get_axis("move_left", "move_right")
	is_facing_right = false if wall_dir > 0 else true

	sprite.flip_h = wall_dir > 0
	if input_dir == wall_dir:
		velocity.y = min(velocity.y + gravity * delta, wall_slide_speed)


func update_state() -> void:
	if is_on_wall_only() and abs(velocity.y) > 0:
		current_state = State.WallSlide
	elif is_dashing:
		current_state = State.Dash
	elif !is_on_floor():
		current_state = State.Jump
	elif abs(velocity.x) > 1.0:
		current_state = State.Walk
	else:
		current_state = State.Idle


func animate() -> void:
	if is_past:
		match current_state:
			State.Idle:
				sprite.play("idle_past")
			State.Walk:
				sprite.play("walk_past")
			State.Jump:
				sprite.play("jump_past")
				sprite.frame = 3
			State.WallSlide:
				sprite.play("wall_slide_past")
			State.Dash:
				sprite.play("dash_past")
	else:
		match current_state:
			State.Idle:
				sprite.play("idle_future")
			State.Walk:
				sprite.play("walk_future")
			State.Jump:
				sprite.play("jump_future")
			State.WallSlide:
				sprite.play("wall_slide_future")
			State.Dash:
				sprite.play("dash_future")
			

func change_time(is_red_active):
	is_past = is_red_active
	
func get_wall_direction() -> int:
	var wall_normal = get_wall_normal()
	return -sign(wall_normal.x)
	
func set_respawn_position(pos: Vector2):
	respawn_position = pos

func respawn():
	velocity = Vector2.ZERO
	global_position = respawn_position
	set_deferred("global_position", respawn_position)
	get_parent().spawn_alien_at_player_respawn()

func check_death():
	if position.y > 0:
		respawn()
