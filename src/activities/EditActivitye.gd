extends Node

var Etat = preload("res://src/entities/Etat.tscn")
var Instruction = preload("res://src/entities/Instruction.tscn")


var rejected = []

func _ready():
	pass

func _process(delta):
	#print(_get_transitions($Automate/Etats/Etat))
	pass

func is_accessible(etat):
	return _is_etat_accessible(_get_etat_initial(), etat)

func is_coaccessible(etat):
	return _is_etat_coaccessible(etat, etat)

func smiplifier():
	var instructions = $Automate/Instructions.get_children()
	for ins in instructions:
		if decomposer(ins):
			delete_instruction(ins)

func decomposer(instrcution):
	var delete_ins = true
	var index_deleted = []
	var index = 0
	for word in instrcution.mot_lu:
		if word.length() > 1:
			index_deleted.append(index)
			var new_etats = []
			var new_ins = []
			#create
			for i in range(word.length()):
				var c = word[i]
				var inc = Instruction.instance()
				inc.connect("right_click_instruction", $Automate, "_on_right_click_instruction")
				inc.mot_lu.append(c)
				if i == 0:
					inc.etat_debut = instrcution.etat_debut
				if i == (word.length() - 1):
					inc.etat_fin = instrcution.etat_fin
				new_ins.append(inc)
			for i in range(word.length() - 1):
				var etat = Etat.instance()
				etat.connect("right_click_etat", $Automate, "_on_Etat_right_click_etat")
				etat.nom = word[i] + word[i+1]
				new_etats.append(etat)
			var i = 0
			#link
			for etat in new_etats:
				if i == 0:
					new_ins[i].etat_debut = instrcution.etat_debut
					new_ins[i].etat_fin = etat
					if new_etats.size() == 1:
						new_ins[i+1].etat_debut = etat
						new_ins[i+1].etat_fin = instrcution.etat_fin
				elif i == new_etats.size() - 1:
					new_ins[i].etat_debut = new_etats[i-1]
					new_ins[i].etat_fin = etat
					new_ins[i+1].etat_debut = etat
					new_ins[i+1].etat_fin = instrcution.etat_fin
				else:
					new_ins[i].etat_debut = new_etats[i-1]
					new_ins[i].etat_fin = etat
				i += 1
			#display
			for etat in new_etats:
				etat.position = _get_nearest_position(instrcution.etat_debut.position)
				$Automate/Etats.add_child(etat)
			for ins in new_ins:
				$Automate/Instructions.add_child(ins)
			#for debug
			for etat in new_etats:
				print(etat.nom)
			for ins in new_ins:
				print(ins.etat_debut.nom, ins.mot_lu, ins.etat_fin.nom)
		else:
			delete_ins = false
		index += 1
	if not delete_ins:
		for id in index_deleted:
			instrcution.mot_lu.remove(id)
		if instrcution.etat_debut == instrcution.etat_fin:
			instrcution.etat_debut.show_boucle(instrcution.mot_lu)
	return delete_ins

func delete_epsilons():
	for etat_epsilon in _get_etats_epsilon():
		for clos in _get_epsilon_clos(etat_epsilon, []):
			for trans in _get_transitions(clos):
				for etat in _get_epsilon_clos_trans(trans.etat_fin):
					add_trans(etat_epsilon, etat, trans.mot_lu)
	
	for ins in $Automate/Instructions.get_children():
		if _delete_char(ins.mot_lu, "€"):
			ins.queue_free()

func _get_etats_epsilon():
	var etats = []
	for ins in $Automate/Instructions.get_children():
		if "€" in ins.mot_lu:
			etats.append(ins.etat_debut)
	return etats

func _get_epsilon_clos(etat_epsilon, etats): #(etat_epsilon, [])
	var clos = etats
	if not(etat_epsilon in clos):
		clos.append(etat_epsilon)
		for suc in _get_successeur_mot(etat_epsilon, "€"):
			clos.append(_get_epsilon_clos(suc, clos))
		return clos
	else:
		return clos

func _get_transitions(epsilon_clos):
	return _get_instruction_without_mot(epsilon_clos, "€")


func _get_epsilon_clos_trans(transitions):
	return _get_epsilon_clos(transitions, [])

func add_trans(etat_debut, etat_fin, mot):
	if not _trans_exist(etat_debut, etat_fin, mot):
		var new_ins = Instruction.instance()
		new_ins.etat_debut = etat_debut
		new_ins.etat_fin = etat_fin
		new_ins.mot_lu = mot
		new_ins.connect("right_click_instruction", $Automate, "_on_right_click_instruction")
		if new_ins.etat_debut == new_ins.etat_fin:
			new_ins.etat_debut.show_boucle(new_ins.mot_lu)
		else:
			$Automate/Instructions.add_child(new_ins)
	pass

func _trans_exist(etat_debut, etat_fin, mot):
	for ins in $Automate/Instructions.get_children():
		if (etat_debut == ins.etat_debut) and (etat_fin == ins.etat_fin) and (mot in ins.mot_lu):
			return true
	return false

func _delete_char(variable, mot):
	var delete_ins = false
	if variable is Array:
		variable.erase(mot)
		if variable.size() == 0:
			delete_ins = true
	elif variable is String:
		variable.erase(variable.find(mot), 1)
		if variable.length() == 0:
			delete_ins = true
	return delete_ins

func _get_nearest_position(from_pos : Vector2):
	var position = from_pos
	var etats = $Automate/Etats.get_children()
	var instrcutions = $Automate/Instructions.get_children()
	var taken = []
	for etat in etats:
		taken.append(etat.position)
	for ins in instrcutions:
		taken.append(ins.get_position())
	while(_is_colliding(position, taken)):
		position += Vector2(40, 40)
	return position

func _is_colliding(point : Vector2, points):
	for p in points:
		if not (point.distance_to(p) >= 120):
			return true
	return false

func _is_etat_accessible(etat_initial, etat):
	if etat.initial:
		return true
	var current_etat = etat_initial
	if current_etat == _get_etat_initial():
		rejected.clear()
	if current_etat == etat:
		return false
	rejected.append(current_etat)
	for suc in _get_successeur(current_etat):
		if suc in rejected:
			continue
		if suc == etat:
			return true
		else:
			rejected.append(suc)
			if _is_etat_accessible(suc, etat):
				return true
	if etat_initial == _get_etat_initial(): 
		return false

func _is_etat_coaccessible(etat, etat_root):
	if etat.final:
		return true
	if etat == etat_root:
		rejected.clear()
	rejected.append(etat)
	for suc in _get_successeur(etat):
		if suc.final:
			return true
		if suc in rejected:
			continue
		else:
			rejected.append(suc)
	for suc in _get_successeur(etat):
		if _is_etat_coaccessible(suc, etat_root):
			return true
	if etat == etat_root:
		return false

func _get_etat_initial():
	for etat in $Automate/Etats.get_children():
		if etat.initial:
			return etat

func _get_successeur(etat):
	var instructions = $Automate/Instructions.get_children()
	var sucs = []
	for ins in instructions:
		if ins.etat_debut == etat:
			sucs.append(ins.etat_fin)
	return sucs

func _get_successeur_mot(etat, mot):
	var instructions = $Automate/Instructions.get_children()
	var sucs = []
	for ins in instructions:
		if (ins.etat_debut in etat) and (mot in ins.mot_lu):
			sucs.append(ins.etat_fin)
	return sucs

func _get_instruction_without_mot(etat_debut, mot):
	var instructions = $Automate/Instructions.get_children()
	var sucs = []
	for ins in instructions:
		if (ins.etat_debut == etat_debut) and (mot in ins.mot_lu):
			if ins.mot_lu.size() == 1:
				continue
			sucs.append(ins)
		else:
			sucs.append(ins)
	return sucs

func _get_predecesseur(etat):
	pass

func delete(etat):
	for child in $Automate/Instructions.get_children():
		if (child.etat_debut == etat) or (child.etat_fin == etat):
			child.queue_free()
		etat.queue_free()

func delete_instruction(instruction):
	if instruction.etat_debut == instruction.etat_fin:
		instruction.etat_debut.hide_boucle()
	instruction.queue_free()

func reorganize_positions():
	var PosEtats = $Automate/Positions/PosEtats.get_children()
	var PosInstructions = $Automate/Positions/PosInstructions.get_children()
	var i = 0
	for etat in $Automate/Etats.get_children():
		etat.position = PosEtats[i].position
		i += 1
	i = 0
	for ins in $Automate/Instructions.get_children():
		ins.set_arrow_positoin(PosInstructions[i].position)
		i += 1

func _on_ReductionDialog_confirmed():
	for etat in $Automate/Etats.get_children():
		if (not is_accessible(etat)) or (not is_coaccessible(etat)):
			delete(etat)


func _on_PopupOperations_id_pressed(id):
	match id:
		1:#Réduction
			$GUI/ReductionDialog/MarginContainer/Tree.clear()
			var root = $GUI/ReductionDialog/MarginContainer/Tree.create_item()
			root.set_text(0, "Etats")
			var etats = $GUI/ReductionDialog/MarginContainer/Tree.create_item(root)
			etats.set_text(0, "Etats accessibles et co-accessibles")
			for etat in $Automate/Etats.get_children():
				if is_accessible(etat) and is_coaccessible(etat):
					var child = $GUI/ReductionDialog/MarginContainer/Tree.create_item(etats)
					child.set_text(0, etat.nom)
			var etats_non_acc = $GUI/ReductionDialog/MarginContainer/Tree.create_item(root)
			etats_non_acc.set_text(0, "Etats non accessibles")
			for etat in $Automate/Etats.get_children():
				if not is_accessible(etat):
					var child = $GUI/ReductionDialog/MarginContainer/Tree.create_item(etats_non_acc)
					child.set_text(0, etat.nom)
			var etats_non_coacc = $GUI/ReductionDialog/MarginContainer/Tree.create_item(root)
			etats_non_coacc.set_text(0, "Etats non co-accessibles")
			for etat in $Automate/Etats.get_children():
				if not is_coaccessible(etat):
					var child = $GUI/ReductionDialog/MarginContainer/Tree.create_item(etats_non_coacc)
					child.set_text(0, etat.nom)
			$GUI/ReductionDialog.popup_centered_ratio(0.4)
		2:#simplifier
			smiplifier()
			delete_epsilons()


func _on_PopupAutomate_id_pressed(id):
	match id:
		0: #reorganizer
			reorganize_positions()
