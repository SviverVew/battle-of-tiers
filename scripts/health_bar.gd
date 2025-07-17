## res://ui/health_bar.gd
extends Control

@export var show_when_full: bool = true

var _max_hp: float = 100.0
var _hp: float = 100.0

@onready var bar: ProgressBar = $Bar

func _ready():
	_update_bar()

func set_max_hp(value: float):
	_max_hp = value
	bar.max_value = _max_hp
	_update_bar()

func set_hp(value: float):
	_hp = clamp(value, 0, _max_hp)
	_update_bar()

func _update_bar():
	bar.value = _hp
	visible = show_when_full or _hp < _max_hp
