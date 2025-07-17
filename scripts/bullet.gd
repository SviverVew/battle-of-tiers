extends Area2D

@export var speed := 300.0
@export var damage := 20
var target: Node
var shooter_team := 0          # optional

func _ready():
	body_entered.connect(Callable(self, "_on_body_entered"))

func _physics_process(delta):
	if target == null or !is_instance_valid(target):
		queue_free()
		return
	var dir: Vector2 = (target.global_position - global_position).normalized()
	rotation = dir.angle()
	position += dir * speed * delta

func _on_body_entered(body: Node) -> void:
	# Va trúng bất kỳ địch nào → gây dmg
	if body.has_method("is_enemy") and body.is_enemy(shooter_team):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
