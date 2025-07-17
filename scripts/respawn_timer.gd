extends Control
"""
Hiển thị đếm ngược hồi sinh. 
Gọi start_respawn(thời_gian) để bắt đầu.
Khi đếm xong sẽ tự gọi get_parent().respawn().
"""

@onready var label: Label = $Label
@onready var timer: Timer = $Timer
var time_left: int = 0

func start_respawn(duration: float) -> void:
	print("🚨 TIMER:", timer)
	print("🚨 TIMER TYPE:", typeof(timer))
	if timer == null:
		print("❌ Timer is null! Check your $Timer path.")
	if not timer is Timer:
		print("❌ Not a Timer node!")

	time_left = int(ceil(duration))
	label.visible = true
	_update_label()
	timer.start(1.0)
		   # Timer timeout mỗi 1 giây

func _update_label() -> void:
	label.text = "Hồi sinh sau: %ds" % time_left

func _on_Timer_timeout() -> void:
	time_left -= 1
	if time_left <= 0:
		timer.stop()
		label.visible = false
		get_parent().respawn()      # Gọi hàm respawn của Player
	else:
		_update_label()
