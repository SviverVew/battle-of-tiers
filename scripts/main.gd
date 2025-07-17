extends Node2D


func _on_btn_start_pressed() -> void:
	get_tree().change_scene_to_file("res://map.tscn")
	pass # Replace with function body.


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
