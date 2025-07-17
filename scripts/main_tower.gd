extends Node2D

@export var team_id := 0
@export var attack_range := 200
@export var attack_cooldown := 1.5 # giây giữa 2 đòn
@export var damage := 20
@export var bullet_scene : PackedScene = preload("res://Bullet.tscn")
@export var bullet_speed := 100
var direction: Vector2 = Vector2.RIGHT

var enemies_in_range: Array = []
var can_attack := true

func _ready():
	$DetectionArea.connect("body_entered", Callable(self, "_on_body_entered"))
	$DetectionArea.connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta):
	if can_attack and enemies_in_range.size() > 0:
		var target = enemies_in_range[0] # Ưu tiên thằng đầu tiên
		if is_instance_valid(target):
			attack(target)
			can_attack = false
			await get_tree().create_timer(attack_cooldown).timeout
			can_attack = true

func _on_body_entered(body):
	if body.has_method("is_enemy") and body.is_enemy(team_id):
		enemies_in_range.append(body)

func _on_body_exited(body):
	enemies_in_range.erase(body)
	print("ENTER:", body.name, "is_enemy:", body.has_method("is_enemy") and body.is_enemy(team_id))


func attack(target):
	var b := bullet_scene.instantiate()
	b.global_position = $"Muzzle".global_position
	b.target = target          # gán reference, không cần direction nữa
	b.damage = damage
	get_tree().current_scene.add_child(b)
