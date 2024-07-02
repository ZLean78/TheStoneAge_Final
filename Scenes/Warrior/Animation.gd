extends Node2D


func _animate(_velocity,_sprite,_target_position):
	if _velocity == Vector2(0,0):
		if _sprite.animation == "male_backwalk_d":
			_sprite.animation = "male_idle2_d"
		elif _sprite.animation == "male_frontwalk_d":
			_sprite.animation = "male_idle1_d"
		elif _sprite.animation == "male_sidewalk_d":
			_sprite.animation = "male_idle3_d"
	else:
		if _velocity.y < 0:
			if abs(_velocity.y) > abs(_velocity.x):
				_sprite.animation = "male_backwalk_d"
			else:
				_sprite.animation = "male_sidewalk_d"
		elif _velocity.y > 0:
			if abs(_velocity.y) > abs(_velocity.x):
				_sprite.animation = "male_frontwalk_d"
			else:
				_sprite.animation = "male_sidewalk_d"
		elif _velocity.x < 0:
			if abs(_velocity.x) > abs(_velocity.y):
				_sprite.animation = "male_sidewalk_d"
			else:
				_sprite.animation = "male_backwalk_d"
		elif _velocity.x > 0:
			if abs(_velocity.x) > abs(_velocity.y):
				_sprite.animation = "male_sidewalk_d"
			else:
				_sprite.animation = "male_frontwalk_d"
				

	if position.distance_to(_target_position) < 5:
		_sprite.animation = "male_idle1_d"
