extends Node2D

var points = 30
onready var the_sprite = null
var type=null
var touching = false
var empty = false
var mouse_entered=false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _physics_process(_delta):
	pass
	


func _on_Area2D_body_entered(body):
	if("Citizen" in body.name):
		touching = true
		body._set_pickable_touching(true)
		body._set_pickable(self)
		if type == "fruit_tree":
			body.is_sheltered=true
		if type == "lake":
			body._set_lake_touching(true)
		elif type == "puddle":
			body._set_puddle_touching(true)
	


func _on_Area2D_body_exited(body):
	if("Citizen" in body.name):
		touching = false
		body._set_pickable_touching(false)
		body._set_pickable(null)
		if type == "fruit_tree":
			body.is_sheltered=false
		if type == "lake":
			body._set_lake_touching(false)			
		elif type == "puddle":
			body._set_puddle_touching(false)
		

func _on_Area2D_mouse_entered():
	mouse_entered=true
	var tree = Globals.current_scene
	if tree.name == "Game":
		if type == "fruit_tree":
			get_parent().get_parent().emit_signal("is_basket")
		elif type == "plant":
			get_parent().get_parent().emit_signal("is_basket")	
	if tree.name == "Game2":
		if type == "fruit_tree":
			get_parent().get_parent().emit_signal("is_basket")
		elif type == "plant":
			get_parent().get_parent().emit_signal("is_basket")	
		elif type == "pine_tree":
			get_parent().get_parent().emit_signal("is_axe")
		elif type == "quarry":
			tree.emit_signal("is_pick_mattock")	
		elif type == "puddle":
			tree.emit_signal("is_hand")	
		elif type == "lake":
			tree.emit_signal("is_claypot")	
	if tree.name == "Game3":
		if !tree.house_mode && !tree.townhall_mode:
			if type == "fruit_tree":
				get_parent().get_parent().emit_signal("is_basket")
			elif type == "plant":
				get_parent().get_parent().emit_signal("is_basket")	
			elif type == "pine_tree":
				get_parent().get_parent().emit_signal("is_axe")
			elif type == "quarry":
				tree.emit_signal("is_pick_mattock")	
			elif type == "puddle":
				tree.emit_signal("is_hand")	
			elif type == "lake":
				tree.emit_signal("is_claypot")
	if tree.name == "Game4" || tree.name == "Game5":
		if !tree.house_mode && !tree.fort_mode && !tree.tower_mode && !tree.barn_mode:
			if type == "fruit_tree":
				get_parent().get_parent().emit_signal("is_basket")
			elif type == "plant":
				get_parent().get_parent().emit_signal("is_basket")	
			elif type == "pine_tree":
				get_parent().get_parent().emit_signal("is_axe")
			elif type == "quarry":
				get_parent().get_parent().emit_signal("is_pick_mattock")	
			elif type == "copper":
				get_parent().get_parent().emit_signal("is_pick_mattock")	
			elif type == "puddle":
				get_parent().emit_signal("is_hand")	
			elif type == "lake":
				if tree.arrow_mode:
					get_parent().emit_signal("is_claypot")
				if tree.house_mode:
					get_parent().emit_signal("is_house")


func _on_Area2D_mouse_exited():
	mouse_entered=false
	var tree = Globals.current_scene
	if tree.name == "Game":
		if type == "fruit_tree" or type == "plant":
			get_parent().get_parent().emit_signal("is_arrow")
	if tree.name == "Game2":
		if type == "fruit_tree" or type == "plant" or type == "pine_tree":
			get_parent().get_parent().emit_signal("is_arrow")
		elif type == "quarry" or type == "puddle" or type == "lake":
			tree.emit_signal("is_arrow")
			if type=="lake":
				if tree.name == "Game2":
					tree.prompts_label.text = tree.start_string
	if tree.name == "Game3":
		if !tree.house_mode && !tree.townhall_mode:
			if type == "fruit_tree" or type == "plant" or type == "pine_tree":
				get_parent().get_parent().emit_signal("is_arrow")
			elif type == "quarry" or type == "puddle" or type == "lake":
				tree.emit_signal("is_arrow")
	if tree.name == "Game4" || tree.name == "Game5":
		if !tree.house_mode && !tree.fort_mode && !tree.tower_mode && !tree.barn_mode:
			if type == "fruit_tree" or type == "plant" or type == "pine_tree":
				get_parent().get_parent().emit_signal("is_arrow")
			elif type == "quarry" or type == "puddle" or type == "lake" or type == "copper":
				tree.emit_signal("is_arrow")
				


