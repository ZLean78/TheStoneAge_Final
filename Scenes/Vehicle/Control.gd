extends Node2D

onready var tree_instance
onready var unit_instance

func _ready():
	tree_instance=Globals.current_scene
	unit_instance=get_parent()

func _unhandled_input(event):
	if event.is_action_pressed("RightClick"):
		if unit_instance.selected:
			if tree_instance.sword_mode:
				unit_instance._shoot()
				unit_instance.just_shot=true
			else:
				unit_instance._move()
			
		
		
