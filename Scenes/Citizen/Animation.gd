extends Node2D



func _animate(sprite,is_dressed,is_girl,bag_sprite,velocity,target_position):
	if(!is_dressed):
		if(!is_girl):
			if velocity == Vector2(0,0):
				if sprite.animation == "male_backwalk":
					sprite.animation = "male_idle2"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_2"
				elif sprite.animation == "male_frontwalk":
					sprite.animation = "male_idle1"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_1"
				elif sprite.animation == "male_sidewalk":
					sprite.animation = "male_idle3"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_3"
#				else:
#					$sprite.animation = "male_idle1"
			else:
				if velocity.y < 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "male_backwalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_2"
					else:
						sprite.animation = "male_sidewalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
				elif velocity.y > 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "male_frontwalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_1"
					else:
						sprite.animation = "male_sidewalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
				elif velocity.x < 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "male_sidewalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
					else:
						sprite.animation = "male_backwalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_2"
				elif velocity.x > 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "male_sidewalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
					else:
						sprite.animation = "male_frontwalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_1"
#				else:
#				$sprite.animation = "male_idle1"			
		else:
			if velocity == Vector2(0,0):
				if sprite.animation == "female_backwalk":
					sprite.animation = "female_idle2"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_2"
				elif sprite.animation == "female_frontwalk":
					sprite.animation = "female_idle1"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_1"
				elif sprite.animation == "female_sidewalk":
					sprite.animation = "female_idle3"	
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_3"	
#				else:
#					$sprite.animation = "female_idle1"
			else:
				if velocity.y < 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "female_backwalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_2"
					else:
						sprite.animation = "female_sidewalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
				elif velocity.y > 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "female_frontwalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_1"
					else:
						sprite.animation = "female_sidewalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
				elif velocity.x < 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "female_sidewalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
					else:
						sprite.animation = "female_backwalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_2"
				elif velocity.x > 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "female_sidewalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
					else:
						sprite.animation = "female_frontwalk"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_1"
#				else:
#					$sprite.animation = "female_idle1"	
	else:
		if(!is_girl):
			if velocity == Vector2(0,0):
				if sprite.animation == "male_backwalk_d":
					sprite.animation = "male_idle2_d"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_2"
				elif sprite.animation == "male_frontwalk_d":
					sprite.animation = "male_idle1_d"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_1"
				elif sprite.animation == "male_sidewalk_d":
					sprite.animation = "male_idle3_d"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_3"
#				else:
#					$sprite.animation = "male_idle1"
			else:
				if velocity.y < 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "male_backwalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_2"
					else:
						sprite.animation = "male_sidewalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
				elif velocity.y > 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "male_frontwalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_1"
					else:
						sprite.animation = "male_sidewalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
				elif velocity.x < 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "male_sidewalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
					else:
						sprite.animation = "male_backwalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_2"
				elif velocity.x > 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "male_sidewalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
					else:
						sprite.animation = "male_frontwalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_1"
#				else:
#				$sprite.animation = "male_idle1"			
		else:
			if velocity == Vector2(0,0):
				if sprite.animation == "female_backwalk_d":
					sprite.animation = "female_idle2_d"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_2"
				elif sprite.animation == "female_frontwalk_d":
					sprite.animation = "female_idle1_d"
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_1"
				elif sprite.animation == "female_sidewalk_d":
					sprite.animation = "female_idle3_d"	
					if(bag_sprite.visible):
						bag_sprite.animation = "bag_3"	
#				else:
#					$sprite.animation = "female_idle1"
			else:
				if velocity.y < 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "female_backwalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_2"
					else:
						sprite.animation = "female_sidewalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
				elif velocity.y > 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "female_frontwalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_1"
					else:
						sprite.animation = "female_sidewalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
				elif velocity.x < 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "female_sidewalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
					else:
						sprite.animation = "female_backwalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_2"
				elif velocity.x > 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "female_sidewalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_3"
					else:
						sprite.animation = "female_frontwalk_d"
						if(bag_sprite.visible):
							bag_sprite.animation = "bag_1"
#				else:
#					$sprite.animation = "female_idle1"	
		

	
	
	#if position.distance_to(get_node("Single_Tap_Device/Target_Position").position) < 5:
	#target_position = get_global_mouse_position()
	if position.distance_to(target_position) < 5:
		if(!is_dressed):
			if(!is_girl):
				sprite.animation = "male_idle1"
			else:
				sprite.animation = "female_idle1"
		else:
			if(!is_girl):
				sprite.animation = "male_idle1_d"
			else:
				sprite.animation = "female_idle1_d"
		if(bag_sprite.visible):
			bag_sprite.animation = "bag_1"
	



