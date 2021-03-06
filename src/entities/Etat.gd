extends KinematicBody2D


export var nom : String
export var final : bool
export var initial : bool

signal right_click_etat(etat)
signal right_click_boucle(etat)
signal etat_linked(etat_fin)

const white = Color(1, 1, 1, 1)
const blue = Color(0, 0, 1, 1)

var drag = false
var drag_start_position

func _ready():
	$Nom.text = nom
	if not final:
		$SpriteFinal.hide()
	if not initial:
		$SpriteInitial.hide()

func _process(delta):
	if (drag) and (Input.is_action_pressed("click")):
		move_and_slide((get_global_mouse_position() - position) * 50)

func set_final(is_final):
	if is_final:
		final = true
		$SpriteFinal.show()
	else:
		final = false
		$SpriteFinal.hide()

func set_initial(is_initial):
	if is_initial:
		initial = true
		$SpriteInitial.show()
	else:
		initial = false
		$SpriteInitial.hide()

func _on_Etat_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			drag = true
		else:
			drag = false 
	if event.is_action_pressed("ui_right_mouse"):
		emit_signal("right_click_etat", self)

func show_boucle(word):
	var text = String(word)
	$Boucle/BoucleLabel.text = text
	$Boucle.show()

func hide_boucle():
	$Boucle.hide()


func _on_Boucle_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ui_right_mouse"):
		emit_signal("right_click_boucle", self)

func save():
	var save_dict = {
		"nom" : nom,
		"final" : final,
		"initial" : initial,
		"boucle" : $Boucle.visible,
		"boucle_word" : $Boucle/BoucleLabel.text,
		"pos_x" : position.x,
		"pos_y" : position.y
	}
	return save_dict
