extends StaticBody2D

var mouse_entered=false
var sheltered_units=0
var tree

func _ready():
	tree=Globals.current_scene


func _on_Area2D_body_entered(body):
	if tree.name=="Game" && "Citizen" in body.name:
		body.visible=false
		sheltered_units+=1


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && tree.arrow_mode:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				if tree.name=="Game2":
					tree.develop_stone_weapons.visible = not tree.develop_stone_weapons.visible
					tree.invent_wheel.visible = not tree.invent_wheel.visible
					tree.discover_fire.visible = not tree.discover_fire.visible
					tree.make_claypot.visible = not tree.make_claypot.visible
					tree.develop_agriculture.visible = not tree.develop_agriculture.visible

		
				


func _on_Area2D_mouse_entered():
	mouse_entered=true


func _on_Area2D_mouse_exited():
	mouse_entered=false
