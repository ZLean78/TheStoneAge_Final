extends Node2D

var health=0



func _set_health(var _health):
	health = _health
	_update_energy()



func _update_energy():
	$Background.get_child(0).scale.x = health*scale.x/100
	


