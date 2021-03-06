extends Node2D

signal right_click_instruction(instruction)


var etat_debut : KinematicBody2D
var mot_lu = []
var etat_fin : KinematicBody2D

var color = Color(1, 1, 1, 1)
var drag : bool

func _draw():
	if etat_debut == etat_fin:
		$Arrow.hide()
		$Arrow/CollisionShape2D.disabled = true
		return
		
	var center = (etat_debut.position + etat_fin.position) / 2
	var start = etat_debut.position
	var end = etat_fin.position
	var start_angle = atan2(start.y - center.y, start.x - center.x)
	var end_angle = atan2(end.y - center.y, end.x - center.x)
	var start_inverse = 45
	var end_iverse = 135
	var radius = etat_debut.position.distance_to(center)
	
	#draw link
	draw_line(etat_debut.position, $Arrow.position, color, 10)
	draw_line($Arrow.position, etat_fin.position, color, 10)
	#if inverse:
		#draw_arc(center, radius, end_iverse, start_inverse, 32, Color(1, 1, 1, 1), 10)
	#else:
		#draw_arc(center, radius, start_angle, end_angle, 32, Color(1, 1, 1, 1), 10)
	
	#rotate arrow
	var angle = $Arrow.position.direction_to(end).angle()
	$Arrow.rotation_degrees = rad2deg(angle)
	
	#draw  word
	var word = String(mot_lu)
	var text_pos = Vector2($Arrow.position.x, $Arrow.position.y -50)
	draw_string(load("res://assets/fonts/font_button.tres"), text_pos, word)

# Called when the node enters the scene tree for the first time.
func _ready():
	center_position()

func center_position():
	var center = (etat_debut.position + etat_fin.position) / 2
	$Arrow.position = (etat_debut.position + center) / 2

func _process(delta):
		update()
		if (drag) and (Input.is_action_pressed("click")):
			$Arrow.move_and_slide((get_global_mouse_position() - $Arrow.position) * 50)

func get_position():
	return $Arrow.position

func set_arrow_positoin(position):
	$Arrow.position = position

func _on_Arrow_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			drag = true
		else:
			drag = false 
	if event.is_action_pressed("ui_right_mouse"):
		emit_signal("right_click_instruction", self)

func save():
	var save_dict = {
		"debut" : etat_debut,
		"fin" : etat_fin,
		"mot" : mot_lu,
		"pos_x" : position.x,
		"pos_y" : position.y
	}
	return save_dict
