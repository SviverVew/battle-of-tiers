extends Camera2D
"""
   • follow(target)  : bám target (Player) mượt bằng lerp
   • free_mode(true) : chuyển sang camera tự do
   • free drag       : giữ chuột giữa kéo map
   • zoom in/out     : cuộn wheel
"""

@export var follow_speed: float = 8.0
@export var zoom_step: float   = 0.1        # tỉ lệ zoom
@export var min_zoom: float    = 0.5        # thu nhỏ tối đa
@export var max_zoom: float    = 2.0        # phóng to tối đa

var target: Node = null
var free_mode := false
var dragging := false
var last_mouse := Vector2.ZERO

# ---------- API ----------
func follow(node: Node) -> void:
	target = node
	free_mode = false
	dragging = false

func enable_free() -> void:
	target = null
	free_mode = true

# ---------- UPDATE ----------
func _physics_process(delta: float) -> void:
	if target and not free_mode:
		global_position = global_position.lerp(target.global_position, follow_speed * delta)

func _unhandled_input(event: InputEvent) -> void:
	if not free_mode:
		return

	# --- Drag with middle mouse ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		dragging = event.pressed
		last_mouse = event.position
		get_viewport().set_input_as_handled()

	if dragging and event is InputEventMouseMotion:
		var delta_screen: Vector2 = event.position - last_mouse
		last_mouse = event.position
		global_position -= delta_screen * zoom
		get_viewport().set_input_as_handled()


	# --- Zoom with wheel ---
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		var new_zoom := zoom
		new_zoom += Vector2.ONE * (zoom_step if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -zoom_step)
		new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
		new_zoom.y = new_zoom.x
		zoom = new_zoom
		get_viewport().set_input_as_handled()
