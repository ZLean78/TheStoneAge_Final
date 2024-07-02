extends Node2D

onready var tree_instance
onready var unit_instance

func _ready():
	tree_instance=Globals.current_scene
	unit_instance=get_parent()

func _unhandled_input(event):
	if event.is_action_pressed("RightClick"):
		if tree_instance.name!="Game":
			if tree_instance.sword_mode:
				if tree_instance.touching_enemy!=null:
					if is_instance_valid(tree_instance.touching_enemy):
						if unit_instance.selected && unit_instance.can_shoot:
							unit_instance._shoot()
							if unit_instance.is_warchief:
								for warrior in tree_instance.get_node("Warriors").get_children():
									if warrior.position.distance_to(position):
										warrior._shoot()
					else:					
						if tree_instance.name == "Game3":
							tree_instance._on_Game3_is_arrow()
						if tree_instance.name == "Game2":
							tree_instance._on_Game2_is_arrow()
			else:
				unit_instance.firstPoint=global_position
		else:
			unit_instance.firstPoint=global_position
			
	if event.is_action_released("RightClick"):
		if tree_instance.name!="Game":		
			if !tree_instance.sword_mode:
				unit_instance._walk()
		else:
			unit_instance._walk()
