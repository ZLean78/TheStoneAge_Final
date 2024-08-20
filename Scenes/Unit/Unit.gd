extends KinematicBody2D

#Proyectil, piedra para lanzar al enemigo.
var bullet
export var bullet_scene=preload("res://Scenes/Bullet/Bullet.tscn")
export var stone_scene=preload("res://Scenes/Stone/stone.tscn")

#para guardar el parámetro delta del procedimiento _physics_process(delta)
var to_delta=0.0
#Velocidad
export (float) var SPEED = 100.0
#Máximo de Salud
export (float) var MAX_HEALTH = 100.0
#Salud de la unidad.
export (float) var health = 100

#MÁXIMO Y MÍNIMO DE ENEGÍA QUE LA UNIDAD PUEDE PERDER.
export (float) var MAX_ENERGY_LOSS
export (float) var MIN_ENERGY_LOSS

#Nodo raíz del nivel.
onready var tree=Globals.current_scene



#Contador para considerar acciones en el evento timeout del temporizador "AllTimer"
var timer_count=0

#Variable que indica si está seleccionada la unidad.
var selected = false setget _set_selected



#Barra de Energía
onready var bar

#Pie de selección
onready var foot

#Sprites y shoot point escalables:
onready var sprite
onready var bag_sprite
onready var shoot_node
onready var shoot_point

#PoolVector2Array que indica el camino variable, teniendo en cuenta el Polígono de navegación.
var path = PoolVector2Array()

#Indica si la animación de la unidad debe estar invertida en x.
var is_flipped = false

#Para detección de daño. Cuerpo que ingresa al área 2D
var body_entered



#Vector2 que indica la velocidad en x e y para las animaciones.
var velocity = Vector2()

#Posición adonde la unidad debe moverse.
var target_position = Vector2.ZERO

#Indica si la unidad ha sido marcada para ser eliminada.
var is_erased=false


#Señal de cambio de salud (incremento o decremento).
signal health_change
#Señal de que la unidad ha muerto.
signal im_dead
#signal food_points_change

#Señales que informan si la unidad ha sido seleccionada o desseleccionada.
signal was_selected
signal was_deselected


func _ready():
	connect("was_selected",tree,"_select_unit")
	connect("was_deselected",tree,"_deselect_unit")
	
	
func _set_selected(value):
	if selected != value:
		selected = value
		
		bar.visible = value
		foot.visible = value
		if selected:
			emit_signal("was_selected",self)
		else:
			emit_signal("was_deselected",self)

func _physics_process(delta):
	
	#Limitar la posición de la unidad al tamaño de la pantalla.		
	position.x = clamp(position.x,-1028,tree.screensize.x)
	position.y = clamp(position.y,-608,tree.screensize.y)


func _on_Unit_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				Globals.current_scene._deselect_all()
				_set_selected(not selected)
		
	
func _set_erased(var _is_erased):
	is_erased=_is_erased





