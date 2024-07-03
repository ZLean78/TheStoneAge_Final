extends Node2D




func _on_MouseArea_body_entered(body):
	if ("Cave" in body.name
	|| "Lake" in body.name
	|| "House" in body.name
	|| "Townhall" in body.name
	|| "Tower" in body.name
	|| "Barn" in body.name
	|| "Fort" in body.name
	|| "EnemyTownhall" in body.name
	|| "EnemyTower" in body.name
	|| "EnemyBarn" in body.name 
	|| "EnemyFort" in body.name):
		body.mouse_entered=true


func _on_MouseArea_body_exited(body):
	if ("Cave" in body.name
	|| "Lake" in body.name
	|| "House" in body.name
	|| "Townhall" in body.name
	|| "Tower" in body.name
	|| "Barn" in body.name
	|| "Fort" in body.name
	|| "EnemyTownhall" in body.name
	|| "EnemyTower" in body.name
	|| "EnemyBarn" in body.name 
	|| "EnemyFort" in body.name):
		body.mouse_entered=false
