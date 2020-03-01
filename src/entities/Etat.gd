extends KinematicBody2D


export var nom : String = "S0"
export var final : bool
export var initial : bool

signal right_click_etat()

var drag = false
var drag_start_position

func _ready():
	$Nom.text = nom
	if not final:
		$SpriteFinal.hide()
	if not initial:
		$SpriteInitial.hide()

func _process(delta):
	if drag and Input.is_action_pressed("click"):
		move_and_slide((get_global_mouse_position() - position) * 50)

func _on_Etat_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			drag = true
		else:
			drag = false 
	if event.is_action_pressed("ui_right_mouse"):
		emit_signal("right_click_etat")
