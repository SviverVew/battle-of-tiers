extends CanvasLayer
@onready var left = $Left
@onready var right = $Right
@onready var jump = $Up
@onready var attack = $Atack
@onready var skill1 = $Skill1
@onready var skill2 = $Skill2

func _on_left_pressed() -> void:
	left.modulate.a = 0.5  # Làm mờ nút khi nhấn
func _on_left_released() -> void:
	left.modulate.a = 1.0  # Trả lại rõ khi thả


func _on_right_pressed() -> void:
	right.modulate.a = 0.5 
func _on_right_released() -> void:
	right.modulate.a = 1.0


func _on_up_pressed() -> void:
	jump.modulate.a = 0.5 
func _on_up_released() -> void:
	jump.modulate.a = 1.0


func _on_atack_pressed() -> void:
	attack.modulate.a = 0.5 
func _on_atack_released() -> void:
	attack.modulate.a = 1.0


func _on_skill_1_pressed() -> void:
	skill1.modulate.a = 0.5 
func _on_skill_1_released() -> void:
	skill1.modulate.a = 1.0


func _on_skill_2_pressed() -> void:
	skill2.modulate.a = 0.5 
func _on_skill_2_released() -> void:
	skill2.modulate.a = 1.0
