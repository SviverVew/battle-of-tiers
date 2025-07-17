extends Node2D

@export var creep_scene: PackedScene
@export var team_id: int = 0               # 0 = trái, 1 = phải
@export var spawn_interval: float = 30.0 #thời gian lính tiếp theo ra
@export var enemy_core_x: float = 4000     # toạ độ X của Core địch

func _ready(): #turn lính đầu tiên
	# Delay 15s trước khi spawn wave đầu tiên
	var first_timer := Timer.new()
	first_timer.wait_time = 5.0 #thời gian lính đầu tiên ra
	first_timer.one_shot = true
	first_timer.timeout.connect(_on_first_wave)
	add_child(first_timer)
	first_timer.start()

func _on_first_wave():
	_spawn_wave()

	# Tạo timer lặp lại để spawn wave sau đó
	var t := Timer.new()
	t.wait_time = spawn_interval
	t.autostart = true
	t.timeout.connect(_spawn_wave)
	add_child(t)

func _spawn_wave():
	print("[Spawner] Spawn wave at", global_position)
	for i in 3:
		var c = creep_scene.instantiate()
		c.team_id = team_id
		c.global_position = global_position + Vector2(0, -i * 40)
		print(" --> creep pos", c.global_position)
		get_tree().current_scene.add_child(c)
