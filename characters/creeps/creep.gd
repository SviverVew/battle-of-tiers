extends CharacterBody2D

# ---------- THÔNG SỐ CHUNG ----------
enum State { MOVE, ATTACK }

@export var team_id : int   = 0      # 0 = chạy →
@export var speed   : float = 90
@export var attack_range    : float = 80
@export var attack_damage   : int   = 10
@export var attack_cooldown : float = 0.8
const GRAVITY : float = 1000.0
# ------------------------------------

# ---------- KHAI BÁO HỐ ----------
# Đặt **left < right** theo trục X map
@export var gap1_left  : float = -220   # hố gần base team 0
@export var gap1_right : float = -120

@export var gap2_left  : float =  120   # hố gần base team 1
@export var gap2_right : float =  220
# ----------------------------------

var state : State = State.MOVE
var current_target : Node = null
var crossed : Array[bool] = [false, false]   # đã teleport ở gap1, gap2?

@onready var detect    := $Detection
@onready var atk_timer := $AttackTimer
@onready var anim      := $AnimatedSprite2D
# ===================================

func _ready():
	detect.body_entered.connect(_on_body_entered)
	detect.body_exited.connect(_on_body_exited)
	atk_timer.wait_time = attack_cooldown
	atk_timer.timeout.connect(_on_attack)
	anim.play("idle")

func _physics_process(delta):
	match state:
		State.MOVE:
			_move(delta)
		State.ATTACK:
			if current_target == null or !is_instance_valid(current_target):
				_resume_move()
			elif global_position.distance_to(current_target.global_position) > attack_range:
				_resume_move()

# ---------- DI CHUYỂN & TELEPORT ----------
func _move(delta):
	# gravity
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	_teleport_over_gaps()

	var dir := (1 if team_id == 0 else -1)
	velocity.x = dir * speed
	move_and_slide()

func _teleport_over_gaps():
	var gaps = [[gap1_left, gap1_right], [gap2_left, gap2_right]]
	var dir  = (1 if team_id == 0 else -1)

	for i in gaps.size():
		if crossed[i]:
			continue
		var left  = gaps[i][0]
		var right = gaps[i][1]

		if dir > 0:   # team 0, chạy →
			if global_position.x >= left and global_position.x < right:
				global_position.x = right   # sang bờ
				crossed[i] = true
		else:         # team 1, chạy ←
			if global_position.x <= right and global_position.x > left:
				global_position.x = left
				crossed[i] = true

# ---------- STATE & COMBAT ----------
func _resume_move():
	state = State.MOVE
	current_target = null
	atk_timer.stop()

func _on_body_entered(body):
	if body.has_method("is_enemy") and body.is_enemy(team_id):
		if current_target == null:
			current_target = body
			state = State.ATTACK
			atk_timer.start()

func _on_body_exited(body):
	if body == current_target:
		_resume_move()

func _on_attack():
	if current_target and is_instance_valid(current_target):
		if current_target.has_method("take_damage"):
			current_target.take_damage(attack_damage)
	else:
		_resume_move()
