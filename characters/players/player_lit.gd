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

func is_enemy(other: int) -> bool: return team_id != other
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction ==1 || direction ==-1:
		velocity.x = direction * SPEED
		container.scale.x= direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	var is_moving := direction != 0

	if not is_on_floor():
		animate.play("jump")
	elif direction ==1 || direction ==-1:
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
	if !is_dead:
		return  # Khi chưa chết thì không điều khiển cam

	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	global_position += input_dir * cam_speed * delta
