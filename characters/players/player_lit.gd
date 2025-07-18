extends CharacterBody2D
@onready var cam := get_tree().current_scene.get_node("CameraRig/Camera2D")
@export var respawn_timer_path: NodePath   # <− kéo vào đây
@onready var ui_respawn := get_node(respawn_timer_path)
@export var is_dead := false
@export var respawn_time: float = 5.0
@export var spawn_point: Node2D
#@onready var cam := $Camera2D
@export var cam_speed := 300
@export var max_hp: float = 200.0
var hp: float = max_hp
@onready var health_bar := $HealthBar
const SPEED = 400.0
const JUMP_VELOCITY = -400.0
@export var team_id := 1
@onready var animate = get_node("Container/AnimatedSprite2D")
@onready var container = get_node("Container")
var is_attacking := false
var attack_cooldown := 0.5  # Thời gian hồi chiêu 0.5s
var attack_cooldown_timer := 0.0
var jump_count := 0
var max_jumps := 2  # Cho phép 2 lần nhảy
var is_jumping := false
func is_enemy(other: int) -> bool: return team_id != other
func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Reset khi chạm đất
	if is_on_floor():
		jump_count = 0
		is_jumping = false

	# Nhảy tối đa 2 lần
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps:
		# Cho phép jump dù đang attack, nhưng không play jump animation nếu đang attack
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		is_jumping = true
		if not is_attacking:
			animate.play("jump")


	# Di chuyển trái/phải
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		container.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Chuyển animation tùy theo trạng thái
	if not is_attacking:
		if not is_on_floor():
			if velocity.y < 0 and animate.animation != "jump":
				animate.play("jump")
			elif velocity.y > 0 and animate.animation != "fall":
				animate.play("fall")
		elif direction != 0:
			animate.play("run")
		else:
			animate.play("idle")


	move_and_slide()

	

func _ready():
	health_bar.set_max_hp(max_hp)
	health_bar.set_hp(hp)
	cam.follow(self) 

func take_damage(damage: float):
	print(name, "-", damage, "dmg") # In ra log
	hp -= damage
	health_bar.set_hp(hp)
	print("HP còn", hp)
	health_bar.set_hp(hp)
	if hp <= 0:
		die()

func die():
	is_dead = true
	visible = false
	set_physics_process(false)
	cam.set_process(true)  # Cho camera được điều khiển
	ui_respawn.call("start_respawn", respawn_time)
	cam.enable_free()

func respawn():
	hp = max_hp
	global_position = spawn_point.global_position
	visible = true
	is_dead = false
	set_physics_process(true)
	cam.global_position = global_position
	cam.set_process(false)  # Tắt điều khiển cam tự do
	cam.follow(self) 
func _process(delta):
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

	if !is_dead:
		if Input.is_action_just_pressed("attack") and not is_attacking and attack_cooldown_timer <= 0:
			# Attack trên không
			if not is_on_floor() :
				is_attacking = true
				attack_cooldown_timer = attack_cooldown  # Đặt lại hồi chiêu
				animate.play("jump-attack")
				velocity.y = JUMP_VELOCITY * 0.6
				print("Jump attack")
			# Attack dưới đất
			elif is_on_floor():
				is_attacking = true
				attack_cooldown_timer = attack_cooldown  # Đặt lại hồi chiêu
				animate.play("attack")
				print("Attack dưới đất")

	else:
		# Điều khiển camera tự do khi chết
		var input_dir = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized()
		global_position += input_dir * cam_speed * delta

func _on_animated_sprite_2d_animation_finished():
	var current_anim = animate.animation

	if current_anim == "attack" or current_anim == "jump-attack":
		is_attacking = false
		print("Đã tắt attack")

		# Sau khi tắt attack, chuyển animation phù hợp
		if is_on_floor():
			animate.play("idle")
		else:
			animate.play("fall")  # hoặc "jump" tùy theo velocity.y
