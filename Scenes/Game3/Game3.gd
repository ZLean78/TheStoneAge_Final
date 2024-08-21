extends Node2D


#Contador de unidades 
var unit_count = 1



#El jefe ha muerto.
var is_warchief_dead = false


##############VARIABLES ONREADY VAR####################
#Escena Actual
onready var tree = Globals.current_scene

#UI
#Rectángulo Contenedor
onready var rectangle = tree.get_node("UI/Base/Rectangle")

#Etiquetas
onready var timer_label = tree.get_node("UI/Base/TimerLabel")
onready var food_label = tree.get_node("UI/Base/Rectangle/FoodLabel")
onready var prompts_label = tree.get_node("UI/Base/Rectangle/PromptsLabel")
onready var leaves_label = tree.get_node("UI/Base/Rectangle/LeavesLabel")
onready var stone_label = tree.get_node("UI/Base/Rectangle/StoneLabel")
onready var clay_label = tree.get_node("UI/Base/Rectangle/ClayLabel")
onready var wood_label = tree.get_node("UI/Base/Rectangle/WoodLabel")
onready var water_label = tree.get_node("UI/Base/Rectangle/WaterLabel")

#Botones
onready var give_attack_order = tree.get_node("UI/Base/Rectangle/GiveAttackOrder")
onready var make_warchief = tree.get_node("UI/Base/Rectangle/MakeWarchief")
onready var create_house = tree.get_node("UI/Base/Rectangle/CreateHouse")
onready var create_townhall = tree.get_node("UI/Base/Rectangle/CreateTownHall")
onready var create_warrior = tree.get_node("UI/Base/Rectangle/CreateWarriorUnit")

#Cámara
onready var camera = tree.get_node("Camera")

#Temporizadores
onready var all_timer = tree.get_node("all_timer")
onready var tiger_timer = tree.get_node("tiger_timer")


#########FUENTES DE RECURSOS RECOLECTABLES##########
####QUE SON HIJAS DEL TILEMAP#######
onready var puddle = tree.get_node("TileMap/Puddle")
onready var quarry1 = tree.get_node("TileMap/Quarry1")
onready var quarry2 = tree.get_node("TileMap/Quarry2")
onready var lake = tree.get_node("TileMap/Lake")

#Posiciones
#de creación de unidades.
onready var spawn_position = $SpawnPosition
#de creación de tigres.
onready var tiger_spawn = $TigerSpawn
#de objetivo de tigres
onready var tiger_target = $TigerTarget

#####NODOS DE TIPOS DE ENTIDADES##########
#(del equipo del jugador)
onready var units = $Units
onready var fruit_trees=$FruitTrees
onready var pine_trees=$PineTrees
onready var plants=$Plants
onready var warriors = $Warriors
onready var houses = $Houses
onready var nav2d = $nav
onready var townhall_node=$TownHall
onready var tigers=$Tigers
onready var mammoths=$Mammoths
onready var quarries=$Quarries

###CAJAS DE DIÁLOGO POPUPS PERSONALIZADAS####
onready var next_scene_confirmation = $UI/Base/Rectangle/NextSceneConfirmation
onready var exit_confirmation=$UI/Base/ExitConfirmation
onready var replay_confirmation=$UI/Base/Rectangle/ReplayConfirmation

#Arreglo del path de las unidades del jugador.
var path=[]

#Cueva
var cave

#####ESCENAS PRECARGADAS DE ENTIDADES####
export (PackedScene) var Unit2
export (PackedScene) var Warrior
export (PackedScene) var House
export (PackedScene) var TownHall

####ARREGLOS DE ENTIDADES#####
var selected_units=[]
var all_units=[]
var all_plants=[]
var all_trees=[]
var all_pine_trees=[]
var all_quarries=[]
var all_pickables=[]
var sheltered=[]
var all_tigers=[]

#Arreglo que va a incluir todos los obstáculos creados dinámicamente que las
#unidades van a tener que esquivar.
var obstacles=[]

#Variables para dibujar el rectángulo de selección.
var dragging = false
var selected = []
var drag_start = Vector2.ZERO

#Nodo que dibuja el rectángulo de selección de la cámara.
onready var select_draw=$SelectDraw

#Si el rectángulo sale o no invertido a la izquierda.
var is_flipped = false

#Tamaño de pantalla para clamp
var screensize = Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height"))

#Propiedades para evitar crear una construcción encima de otra.
var is_mouse_entered=false
var is_too_close=false

#Propiedades para comprobar si hay tigres o se ha iniciado el conteo para que aparezcan.
var is_tiger=false
var is_tiger_countdown=false

######SEÑALES DE MODOS DEL CURSOR PARA RECOLECCIÓN DE RECURSOS#####
signal is_arrow
signal is_basket
signal is_pick_mattock
signal is_sword
signal is_claypot
signal is_hand
signal is_axe

######VARIABLES DE MODOS DE CURSOR#####
var arrow_mode=false
var basket_mode=false
var mattock_mode=false
var sword_mode=false
var claypot_mode=false
var hand_mode=false
var axe_mode=false
var house_mode=false
var townhall_mode=false

#Mensaje inicial que se muestra en el área de instrucciones.
var start_string = """Selecciona una unidad de tu grupo y haz clic en el botón
"convertir en jefe guerrero" para que pase a ser el jefe de tu tribu."""

#Si el cursor está en forma de espada tocando un tigre, lo guardamos en esta variable.
var touching_enemy

#Variables para crear los guerreros en formación.
var row=0
var column=0

#Variables para crear las unidades civiles en formación.
var unit_row=0
var unit_column=0


func _ready():
	#Seleccionar y reproducir la música con el autoload AudioPlayer.
	AudioPlayer._select_music()
	AudioPlayer.music.play()	
	
	#Mostrar el texto de inicio en la etiqueta de instrucciones.
	prompts_label.text = start_string
	
	#Cargar los arreglos con los hijos de cada nodo
	#de tipos de entidades.
	all_units=units.get_children()
	all_trees=fruit_trees.get_children()
	all_pine_trees=pine_trees.get_children()
	all_plants=plants.get_children()
	all_tigers=tigers.get_children()	
	
	#Posicionar a los tigres que van a aparecer.
	all_tigers[0].position=Vector2(tiger_spawn.position.x,tiger_spawn.position.y-100)
	all_tigers[0].tiger_number=1
	all_tigers[1].position=Vector2(tiger_spawn.position.x,tiger_spawn.position.y-200)
	all_tigers[1].tiger_number=2
	all_tigers[2].position=Vector2(tiger_spawn.position.x,tiger_spawn.position.y-300)
	all_tigers[2].tiger_number=3

	#Agregar las canteras una por una, porque son hijas del Tilemap.
	all_quarries.append(quarry1)
	all_quarries.append(quarry2)
	
	
	#Adjuntar como hijo de la UI el autoload Globals.settings.
	$UI.add_child(Globals.settings)
	
	#Crear 11 unidades aparte de la que ya está.
	for i in range(0,11):
		_create_unit();
	
	#Hacer formar a las unidades.
	for i in range(0,12):
		if i==0:
			all_units[i].position = Vector2(camera.position.x+50,camera.position.y+50)			
		else:
			if i<4:
				all_units[i].position =	Vector2(all_units[i-1].position.x+20,all_units[i-1].position.y)
			elif i>=4 && i<8:
				if i==4:
					all_units[i].position =	Vector2(all_units[0].position.x,all_units[0].position.y+20)
				else:
					all_units[i].position = Vector2(all_units[i-1].position.x+20,all_units[i-1].position.y)
			elif i>=8:
				if i==8:
					all_units[i].position = Vector2(all_units[0].position.x,all_units[0].position.y+40)
				else:
					all_units[i].position = Vector2(all_units[i-1].position.x+20,all_units[i-1].position.y)
	
	#Reconstruir el mapa de navegación.
	_rebake_navigation()
	
	#Agregar ropa y bolso a todas las unidades
	for a_unit in all_units:
		a_unit.is_dressed=true
		a_unit.has_bag=true
		a_unit.bag_sprite.visible=true
		if a_unit.is_girl:
			a_unit.sprite.animation="female_idle1_d"
		else:
			a_unit.sprite.animation="male_idle1_d"
		Globals.group_dressed=true
		Globals.group_has_bag=true
	

	#Poner el cursor en modo flecha.
	emit_signal("is_arrow")
	arrow_mode=true
	basket_mode=false
	mattock_mode=false
	sword_mode=false
	claypot_mode=false
	hand_mode=false
	axe_mode=false
	

func _process(_delta):
	#Si el jefe no está muerto.
	if !is_warchief_dead:
		#Mostrar los valores globales de recursos y el tiempo para el ataque
		#enemigo en las etiquetas.
		timer_label.text = "ATAQUE ENEMIGO: " + str(int(tiger_timer.time_left))
		food_label.text = str(int(Globals.food_points))
		leaves_label.text = str(int(Globals.leaves_points))	
		stone_label.text = str(int(Globals.stone_points))	
		clay_label.text = str(int(Globals.clay_points))
		wood_label.text = str(int(Globals.wood_points))
		water_label.text = str(int(Globals.water_points))
	
		#Controlar las unidades, los mamuts, las casas, la condición de victoria
		#y los modos del mouse.
		_check_units()
		_check_mammoths()
		_check_houses()
		_check_victory()
		_check_mouse_modes()

		#Si no hay tigres y no ha iniciado la cuenta regresiva para que 
		#aparezcan, iniciar el temporizador de tigres y poner en verdadero
		#la condición que evalúa si se está llevando a cabo el conteo.
		if !is_tiger:
			if !is_tiger_countdown:
				tiger_timer.start()
				is_tiger_countdown=true	
	
	
		

#FUNCIONES DE SELECCIONAR Y DESSELECCIONAR UNIDADES#		
func _select_unit(unit):
	if not selected_units.has(unit):
		selected_units.append(unit)
	

func _deselect_unit(unit):
	if selected_units.has(unit):
		selected_units.erase(unit)
	
	
#CONTROL DEL MOUSE Y LAS UNIDADES
func _unhandled_input(event):
	#Si el jefe no está muerto...
	if !is_warchief_dead:		
		#Si se mueve el mouse.
		if event is InputEventMouseMotion:
			#Si el ícono del mouse está en modo casa o centro cívico.
			if house_mode || townhall_mode:
				
				#Agregar las casas como obstáculos.
				for house in houses.get_children():
					if !house in obstacles:
						obstacles.append(house)
						
				#Agregar el centro cívico como obstáculo.
				for a_townhall in townhall_node.get_children():
					if !a_townhall in obstacles:
						obstacles.append(a_townhall)
				
				#Agregar el lago y la cueva a los obstáculos.
				obstacles.append(lake)
				obstacles.append(cave)
				
				#Comprobar que el cursor no esté sobre un obstáculo, con mouse_entered
				#o demasiado cerca de uno, con is_too_close.
				for an_obstacle in obstacles:
					if an_obstacle.mouse_entered:
						is_mouse_entered=true
						break
					else:
						is_mouse_entered=false	

					if an_obstacle.position.distance_to(get_global_mouse_position())<130:
						is_too_close=true
						break
					else:
						is_too_close=false		
		#Si se presiona la tecla derecha.
		if event.is_action_pressed("RightClick"):
			#Si está en modo flecha.
			if arrow_mode:
				#Hacer formar a las unidades seleccionadas.
				for i in range(0,selected_units.size()):
					if i==0:
						selected_units[i].target_position=get_global_mouse_position()
					else:
						if i%4==0:
							selected_units[i].target_position=Vector2(selected_units[0].target_position.x,selected_units[i-1].target_position.y+20)
						else:
							selected_units[i].target_position=Vector2(selected_units[i-1].target_position.x+20,selected_units[i-1].target_position.y)
			#Si está en modo casa o centro cívico.
			if house_mode || townhall_mode:
				#Ponerlo en modo flecha.
				_on_Game3_is_arrow()
			#Si está en alguno de los modos de recolección...
			if basket_mode || axe_mode || mattock_mode || hand_mode || claypot_mode:
				#...dirigir las unidades seleccionadas hasta la posición del mouse.
				for i in range(0,selected_units.size()):
					selected_units[i].target_position=get_global_mouse_position()
		
		#Si se presiona la tecla izquierda del mouse.
		if event is InputEventMouseButton && event.is_action_pressed("LeftClick"):
			#Si está en modo casa o centro cívico, crear el edificio correspondiente.
			if house_mode:
				_create_house()
				
			if townhall_mode:
				_create_townhall()				
			
			if house_mode || townhall_mode:
				#Enviar a los ciudadanos seleccionados a construir el edificio.
				for citizen in units.get_children():
					if citizen.selected:
						citizen.firstPoint=citizen.global_position
						citizen.secondPoint=citizen.target_position
						_on_Game3_is_arrow()
						var arrPath: PoolVector2Array = nav2d.get_simple_path(citizen.firstPoint,citizen.secondPoint,true)
						citizen.firstPoint = arrPath[0]
						citizen.path = arrPath
						citizen.index = 0
		#Tecla Escape. Se utiliza para poner el cursor en modo flecha,
		#cancelando así la construcción de una casa u otra acción.
		if event.is_action_pressed("EscapeKey"):
			#Si el cursor está en modo casa.
			if house_mode || townhall_mode:
				#Ponemos el cursor en modo flecha para cancelar la construcción de una casa.
				_on_Game3_is_arrow()
			else:
				#Si han muerto todas las unidades y no tenemos más recursos
				#para crear nuevas, aparece la caja de "volver a jugar".
				if(all_units.size()==0 && Globals.food_points<15) || is_warchief_dead:
					replay_confirmation.visible=true
				else:
					#Si estamos en medio de una partida, aparece el menú de opciones.
					$UI/Base/Rectangle/OptionsMenu.visible=!$UI/Base/Rectangle/OptionsMenu.visible
		
	
######FUNCIÓN CREAR CENTRO CÍVICO####
func _create_townhall():
	#Crear una variable ciudadanos, para controlar las unidades del jugador,
	#una variable para representar un ciudadano en particular entre los seleccionados,
	#que es el que va a iniciar la construcción del edificio
	#y el edificio propiamente dicho.
	var citizens=units.get_children()
	var the_citizen=null
	var the_townhall=null
	
	#Identificar el ciudadano que va a iniciar la construcción del edificio.
	for citizen in citizens:
		if citizen.selected:
			the_citizen=citizen
	
	#Si el ciudadano específico the_citizen no es null
	if the_citizen!=null:
		#y si se cuenta con los recursos requeridos para construir el edificio,
		#se crea el edificio.
		if Globals.wood_points>=80 && Globals.leaves_points>=90 && Globals.clay_points>=100 && !is_mouse_entered && !is_too_close:					
			#Crear la variable en la que se va a almacenar el nuevo edificio
			#y crear en ella el centro cívico
			var new_townhall=TownHall.instance()
			#Se le establece un máximo de buena condición (barra de energía) de 80.
			new_townhall.condition_max=80
			
			#Se lo sitúa donde el usuario hace clic, con el ícono del mouse
			#en modo con la forma del edificio.
			new_townhall.position = get_global_mouse_position()
			#Se lo agrega al nodo correspondiente al centro cívico.
			townhall_node.add_child(new_townhall)
			#Enviar al ciudadano encargado de iniciar la construcción
			#al lugar donde se ha creado para que le cargue la barra de buena condición.
			if the_citizen.position.x < new_townhall.position.x:
				#Si el nuevo centro cívico está a la derecha.
				the_citizen.target_position=Vector2(new_townhall.position.x-125,new_townhall.position.y)
			else:
				#Si el nuevo centro cívico está a la izquierda.
				the_citizen.target_position=Vector2(new_townhall.position.x+125,new_townhall.position.y)
			#Asignar a la variable the_townhall el nuevo centro cívico en new_townhall.
			the_townhall=new_townhall
			#Restar los recursos que fueron necesarios del inventario.
			Globals.wood_points-=80
			Globals.leaves_points-=90
			Globals.clay_points-=100
			
			#Actualizamos el mapa de navegación con el nuevo centro cívico.
			_rebake_navigation()
	
	#Si el nuevo centro cívico no es nulo (se ha creado),
	#y si hay otros ciudadanos seleccionados, aparte de the_citizen,
	#enviarlos también a construir el edificio.
	if the_townhall!=null:
		for citizen in citizens:
			if citizen.selected && citizen!=the_citizen:
				if citizen.position.x < the_townhall.position.x:
					#Si el nuevo centro cívico está a la derecha.
					citizen.target_position=Vector2(the_townhall.position.x-125,the_townhall.position.y)
				else:
					#Si el nuevo centro cívico está a la izquierda.
					the_citizen.target_position=Vector2(the_townhall.position.x+125,the_townhall.position.y)	
				
func _create_house():
	#Obtenemos los ciudadanos hijos del nodo units.
	var citizens=units.get_children()
	#Obtenemos las casas hijas del nodo houses.
	var dwells=houses.get_children()
	#Contador de casas.
	var dwell_count=0
	#Identificador de un ciudadano seleccionado (si lo hay).
	#Será el que inicie la construcción de la casa.
	var the_citizen=null
	#La casa a construir.
	var the_house=null
		
	#Comprobamos que no haya menos de cuatro ciudadanos por casa.
	for citizen in citizens:
		if (citizens.size()/4)>dwells.size():	
			#Identificamos al primer ciudadano seleccionado para 
			#construir la casa.			
			if citizen.selected:
				the_citizen=citizen
				#Interrumpimos el loop para que no tome a los otros ciudadanos seleccionados.
				break
	
	#Si el ciudadano seleccionado para construir la casa no es nulo.			
	if the_citizen!=null:
		#Si tenemos al menos 20 puntos de madera y 40 de arcilla.
		if Globals.wood_points>=20 && Globals.clay_points>=40 && !is_mouse_entered && !is_too_close:
			#Instanciamos la nueva casa.					
			var new_house=House.instance()
			#Ubicamos la nueva casa en la posición global del mouse.
			new_house.position = get_global_mouse_position()
			#Máximo de puntos de la barra de constitución de una casa.
			new_house.condition_max=20
			#Agregamos la nueva casa al nodo casas.
			houses.add_child(new_house)
			#Actualizamos el mapa de navegación con la nueva casa.
			_rebake_navigation()
			
			#Le marcamos la posición de la casa al ciudadano seleccionado
			#para que vaya a construirla.
			#Posicionamos a la unidad según el lugar en que se encuentre la nueva casa
			#para construirla.
			if the_citizen.position.x < new_house.position.x:
				#Si la nueva casa está a la derecha.
				the_citizen.target_position=Vector2(new_house.position.x-30,new_house.position.y)
			else:
				#Si la nueva casa está a la izquierda.
				the_citizen.target_position=Vector2(new_house.position.x+30,new_house.position.y)
			
			#Identificamos la nueva casa con la variable the_house.
			the_house=new_house
			#Restamos 20 puntos de madera y 40 de arcilla.
			Globals.wood_points-=20
			Globals.clay_points-=40
			#Mensaje de comprobación para la consola.
			print("Se construyó una casa.")
	
	#Si la nueva casa no es nula.
	if the_house!=null:
		#Si hay otros ciudadanos seleccionados, 
		#también los mandamos a construir la casa.
		for citizen in citizens:
			if citizen.selected:
				#Les marcamos la posición de la casa a los ciudadanos seleccionados
				#para que vayan a construirla.
				#Posicionamos a las unidades según el lugar en que se encuentre la nueva casa
				#para construirla.
				if citizen.position.x < the_house.position.x:
					#Si la nueva casa está a la derecha.
					citizen.target_position=Vector2(the_house.position.x-30,the_house.position.y)
				else:
					#Si la nueva casa está a la izquierda.
					citizen.target_position=Vector2(the_house.position.x+30,the_house.position.y)
	
#####FUNCIÓN CHECK HOUSES#####
#Comprueba si ya han sido creadas las cuatro casas necesarias
#para habilitar la construcción del centro cívico.
func _check_houses():
	var dwells=houses.get_children()
	var dwell_count=0	
	
	for dwell in dwells:
		dwell_count+=1
	
	if dwell_count>=4:
		prompts_label.text="Crea un centro cívico."
		create_townhall.visible=true	

######FUNCIÓN DE CREAR UNIDAD CIVIL#####	
func _create_unit(cost = 0):
	#Crear la variable new_Unit y asignarle la nueva unidad.
	var new_Unit = Unit2.instance()
	#Sumar uno al contador de unidades.
	unit_count+=1
	#Si el número es par, será una mujer. Si no, será hombre.
	if(unit_count%2==0):
		new_Unit.is_girl=true
	else:
		new_Unit.is_girl=false
	#Si el grupo ya tiene ropa, también la tendrá la nueva unidad.
	if(Globals.group_dressed):
		new_Unit.is_dressed=true	
	#Si el grupo ya tiene bolsa de recolección, también la tendrá la nueva unidad.
	if(Globals.group_has_bag):
		new_Unit.has_bag=true	
		new_Unit.get_child(3).visible = true
	#Restar los puntos de comida necesarios para crear una unidad.
	Globals.food_points -= cost
	#Determinar a partir de la posición unit_position
	#dónde situar la nueva unidad.
	new_Unit.position = spawn_position.position
	for unit in units.get_children():
		if new_Unit.position==unit.position:
			unit_column+=1
			
		if unit_column==10:
			unit_column=0
			unit_row+=1
		new_Unit.position=spawn_position.position+Vector2(20*unit_column,20*unit_row)		
	
	#Agregar el nuevo ciudadano al nodo units y all arreglo all_units.
	units.add_child(new_Unit)
	all_units.append(new_Unit)

######FUNCIÓN DE CREAR UNIDAD GUERRERO#####
func _create_warrior_unit():
	#Poner en 0 el contador de guerreros.
	var warriors_count=0
	#Comprobar que se tengan los recursos necesarios y de ser así, crear el nuevo guerrero.
	if Globals.food_points>=30 && Globals.wood_points>=20 && Globals.stone_points>=10:
		var new_warrior = Warrior.instance()
		#Posicionar el nuevo guerrero según la posición spawn_position
		#y las variables column y row.
		new_warrior.position = spawn_position.position
		for warrior in warriors.get_children():
			warriors_count+=1				
			if new_warrior.position == warrior.position:
				column+=1
			
			if column==10:
				column=0
				row+=1
			new_warrior.position=spawn_position.position+Vector2(20*column,20*row)
		
		#Añadir el nuevo guerrero al nodo warriors y al arreglo all_units.
		warriors.add_child(new_warrior)
		all_units.append(new_warrior)
		#Restar los recursos correspondientes.
		Globals.food_points-=30
		Globals.wood_points-=20
		Globals.stone_points-=10
		
	#Cambiar el mensaje en la etiqueta de instrucciones cuando se tenga tres
	#guerreros o más.
	if warriors_count>=3:
		prompts_label.text="Cuando consideres que tienes suficientes guerreros,\nenvíalos a pelear contra los mamuts,\nal noroeste del lago."
	
#####FUNCIÓN CHECK VICTORY####
#Para comprobar victoria o derrota, según se haya logrado construir
#el centro cívico, hayan perecido todas las unidades
#y no existan recursos para crear nuevas, o el jefe haya muerto.		
func _check_victory():
	for child in townhall_node.get_children():
		if "TownHall" in child.name:
			if child.condition==80:
				Globals.is_townhall_created=true
	
	
	if Globals.is_townhall_created:
		prompts_label.text = "¡Has ganado!"	
		next_scene_confirmation.visible=true
		
		
	elif(all_units.size()==0 && Globals.food_points<15):
		prompts_label.text = "Has sido derrotado."
		replay_confirmation.visible=true
	else:
		for a_unit in all_units:
			if "Unit" in a_unit.name && a_unit.is_warchief && a_unit.is_deleted:
				is_warchief_dead=true
				prompts_label.text = "Has sido derrotado. Tu jefe ha muerto."
				replay_confirmation.visible=true	
		

		
#Presionar el botón CreateCitizen. Comprueba que haya
#los puntos de comida necesarios y de ser así, llama a la
#función create_unit.	
func _on_CreateCitizen_pressed():
	if Globals.food_points>=15:
		_create_unit(15)
		


#Señal timeout del tiger_timer. Hace visibles los tigres y los pone en estado 0
#(ir al objetivo que se les dio al crearlos).
func _on_tiger_timer_timeout():
	for a_tiger in all_tigers:
		if is_instance_valid(a_tiger):
			a_tiger.visible=true
			a_tiger.state=0

#Desseleccionar todas las unidades (al crear un rectángulo vacío).
func _deselect_all():
	while selected_units.size()>0:
		selected_units[0]._set_selected(false)
	
#Seleccionar la última unidad seleccionada.	
#func _select_last():
#	for unit in selected_units:
#		if selected_units[selected_units.size()-1] == unit:
#			unit._set_selected(true)
#		else:
#			unit._set_selected(false)
	
#Comprobar cuáles unidades se encuentran dentro del rectángulo de selección.	
func get_units_in_area(area):
	var u=[]
	for unit in all_units:
		if unit.position.x>area[0].x and unit.position.x<area[1].x:
			if unit.position.y>area[0].y and unit.position.y<area[1].y:
				u.append(unit)
	return u
	
#Seleccionar las unidades dentro del rectángulo de selección.	
func _area_selected(obj):
	var start=obj.start
	var end=obj.end
	var area=[]
	area.append(Vector2(min(start.x,end.x),min(start.y,end.y)))
	area.append(Vector2(max(start.x,end.x),max(start.y,end.y)))
	var ut = get_units_in_area(area)
	if not Input.is_key_pressed(KEY_SHIFT):
		_deselect_all()
	for u in ut:
		u.selected = not u.selected
		

		
#func start_move_selection(obj):
#	for un in all_units:
#		if un.selected:
#			un.move_unit(obj.move_to_point)
		
######FUNCIONES DE SEÑALES DEL MODO DEL MOUSE######
#(La acción varía según el modo del ícono).	
#Señal de poner el cursor en modo flecha.
func _on_Game3_is_arrow():
	Input.set_custom_mouse_cursor(Globals.arrow)
	arrow_mode=true
	basket_mode=false
	mattock_mode=false
	sword_mode=false
	claypot_mode=false
	hand_mode=false
	axe_mode=false
	house_mode=false
	townhall_mode=false

#Señal de poner el cursor en modo canasta.
func _on_Game3_is_basket():
	if !house_mode && !townhall_mode:
		Input.set_custom_mouse_cursor(Globals.basket)
		basket_mode=true
		arrow_mode=false
		mattock_mode=false
		sword_mode=false
		claypot_mode=false
		hand_mode=false
		axe_mode=false
		house_mode=false
		townhall_mode=false
	
#Señal de poner el cursor en modo pico.
func _on_Game3_is_pick_mattock():
	if !house_mode && !townhall_mode:
		Input.set_custom_mouse_cursor(Globals.pick_mattock)
		mattock_mode=true
		basket_mode=false
		arrow_mode=false
		sword_mode=false
		claypot_mode=false
		hand_mode=false
		axe_mode=false
		house_mode=false
		townhall_mode=false

#Señal de poner el cursor en modo espada.
func _on_Game3_is_sword():
	if !house_mode && !townhall_mode:
		Input.set_custom_mouse_cursor(Globals.sword)
		sword_mode=true
		mattock_mode=false
		basket_mode=false
		arrow_mode=false
		claypot_mode=false
		hand_mode=false
		axe_mode=false
		house_mode=false
		townhall_mode=false

#Señal de poner el cursor en modo mano.
func _on_Game3_is_hand():
	if !house_mode && !townhall_mode:
		Input.set_custom_mouse_cursor(Globals.hand)
		hand_mode=true
		mattock_mode=false
		basket_mode=false
		arrow_mode=false
		sword_mode=false
		claypot_mode=false
		axe_mode=false
		house_mode=false
		townhall_mode=false

#Señal de poner el cursor en modo cuenco de barro.
func _on_Game3_is_claypot():
	if !house_mode && !townhall_mode:
		Input.set_custom_mouse_cursor(Globals.claypot)
		claypot_mode=true
		arrow_mode=false
		basket_mode=false
		mattock_mode=false
		sword_mode=false
		hand_mode=false
		axe_mode=false
		house_mode=false
		townhall_mode=false

#Señal de poner el cursor en mmodo hacha.
func _on_Game3_is_axe():
	if !house_mode && !townhall_mode:
		Input.set_custom_mouse_cursor(Globals.axe)
		axe_mode=true
		arrow_mode=false
		basket_mode=false
		mattock_mode=false
		sword_mode=false
		claypot_mode=false
		hand_mode=false
		house_mode=false
		townhall_mode=false
	
#Función de poner el cursor en mmodo casa.
func _on_Game3_is_house():
	if is_mouse_entered || is_too_close:
		Input.set_custom_mouse_cursor(Globals.house_b)
	else:
		Input.set_custom_mouse_cursor(Globals.house)
	house_mode=true
	arrow_mode=false
	basket_mode=false
	mattock_mode=false
	sword_mode=false
	claypot_mode=false
	hand_mode=false
	axe_mode=false
	townhall_mode=false
				
#Señal de poner el cursor en mmodo cetro cívico.	
func _on_Game3_is_townhall():
	if is_mouse_entered || is_too_close:
		Input.set_custom_mouse_cursor(Globals.townhall_b)
	else:
		Input.set_custom_mouse_cursor(Globals.townhall)	
	townhall_mode=true
	arrow_mode=false
	basket_mode=false
	mattock_mode=false
	sword_mode=false
	claypot_mode=false
	hand_mode=false
	axe_mode=false
	house_mode=false
	
				
#Comprobar las unidades activas y las que murieron para saber si no hubo derrota.
func _check_units():
	for a_unit in all_units:
		if a_unit.is_deleted && is_instance_valid(a_unit):
			if "Unit" in a_unit.name:
				if !a_unit.is_warchief:
					var the_unit=all_units[all_units.find(a_unit,0)]
					all_units.remove(all_units.find(a_unit,0))
					the_unit._die()
			if "Warrior" in a_unit.name:
				var the_unit=all_units[all_units.find(a_unit,0)]
				all_units.remove(all_units.find(a_unit,0))
				the_unit._die()
	




#Presionar el botón MakeWarchief para convertir una unidad civil en jefe guerrero.
func _on_MakeWarchief_pressed():
	#Sólo convierte la unidad seleccionada si es la única que está seleccionada.
	#y muestra el mensaje correspondiente
	if selected_units.size()==1:
		selected_units[0].is_warchief=true
		selected_units[0].warchief_mark.visible=true
		create_warrior.visible=true
		make_warchief.visible=false
		prompts_label.text = "¡Ya tienes a tu jefe! Utilízalo para entrenar unidades militares\ncon el botón de crear unidad militar."
	#Si hay más de una unidad seleccionada, muestra el mensaje de error.
	elif selected_units.size()>1:
		prompts_label.text = "Debes seleccionar una sola unidad."
	#Muestra el mensaje de 'selecciona una unidad', si es que no hay ninguna seleccionada. 
	elif selected_units.size()==0:
		prompts_label.text = "Selecciona una unidad."

#Presionar botón de crear guerrero, llama a la función _create_warrior_unit()
func _on_CreateWarriorUnit_pressed():
	_create_warrior_unit()


#Comprobar mamuts. Si no queda ninguno, se habilita el botón de 'crear casa'
#y se enuncia el nuevo objetivo en la etiqueta de instrucciones.
func _check_mammoths():
	var mammoths_count=0
	
	for mammoth in mammoths.get_children():
		mammoths_count+=1
	
	if mammoths_count==0:
		prompts_label.text="""Regresa cerca de la cueva y haz que tus ciudadanos
		construyan cuatro casas en la zona. Obtén los recursos necesarios
		y haz clic en un ciudadano para llevar a cabo la tarea. Debes construir 
		una casa cada cuatro civiles."""	
		create_house.visible=true

#Presionar botón crear casa. Pone el cursor en modo casa, si es que no estaba así
#(ver _unhandled_input).
func _on_CreateHouse_pressed():
	if !house_mode:
		_on_Game3_is_house()
	else:
		_on_Game3_is_arrow()




#Presionar botón crear centro cívico. Pone el cursor en modo centro cívico, 
#si es que no estaba así ya (ver _unhandled_input).
func _on_CreateTownHall_pressed():
	if !townhall_mode:
		_on_Game3_is_townhall()
	else:
		_on_Game3_is_arrow()
	
#Actualizar mapa de navegación.	
func _update_path(new_obstacle):
	#Ciudadanos	
	var citizens=units.get_children()
	#Variable para un ciudadano en particular, el primero seleccionado.
	var the_citizen=null
	#Construir un nuevo arreglo de vectores.
	var new_polygon=PoolVector2Array()
	#Tomar el obstáculo pasado como referencia y el polígono de colisión del mismo.
	var col_polygon=new_obstacle.get_node("CollisionPolygon2D").get_polygon()
	
	#Cada vector en el polígono de colisión se añade a la posición del obstáculo
	#dado como parámetro y se agrega al nuevo polígono.
	for vector in col_polygon:
		new_polygon.append(vector + new_obstacle.position)		
	
	#Se toma el polígono de colisión del nodo nav2d.	
	var navi_polygon=nav2d.get_node("polygon").get_navigation_polygon()
	#Se le agrega como outline el nuevo polígono. 
	navi_polygon.add_outline(new_polygon)
	#Se invoca la función que hace que el polígono genere de nuevo todos sus
	#polígonos del outline.
	navi_polygon.make_polygons_from_outlines()	
	
	#Se toma el primer ciudadano seleccionado y se interrumpe el ciclo.
	for citizen in citizens:
		if citizen.selected:
			the_citizen=citizen
			break
	
	#A ese ciudadano se le genera el nuevo path.
	if the_citizen!=null:	
		var p = nav2d.get_simple_path(the_citizen.firstPoint,the_citizen.secondPoint,true)
		path = Array(p)
		path.invert()


#####FUNCIÓN RECONSTRUIR NAVEGACIÓN####
func _rebake_navigation():
	#Deshabilitar el polígono de navegación.
	nav2d.get_node("polygon").enabled=false
	#Tomar el polígono de navegación y borrarle los outlines y los polígonos.
	var navi_polygon=nav2d.get_node("polygon").get_navigation_polygon()
	navi_polygon.clear_outlines()
	navi_polygon.clear_polygons()
	
	#Agregar límite general.
	navi_polygon.add_outline(PoolVector2Array([
	Vector2(-1024,-608),
	Vector2(1024,-608),
	Vector2(1024,608),
	Vector2(-1024,608)]))
	
	#Agregar lago.
	_update_path(lake)
	
	#Agregar cueva.
	_update_path(cave)
		
	#Agregar las casas.
	for a_house in houses.get_children():
		if is_instance_valid(a_house):
			_update_path(a_house)
	
	#Agregar el centro cívico.	
	for a_townhall in townhall_node.get_children():
		if is_instance_valid(a_townhall):
			_update_path(a_townhall)
		
	
	#Crear polígonos desde los outlines.	
	navi_polygon.make_polygons_from_outlines()
	#Volver a habilitar el polígono de navegación.	
	nav2d.get_node("polygon").enabled=true
	

	
#Controlar los modos del mouse para casa y centro cívico.	
func _check_mouse_modes():
	if house_mode:
		_on_Game3_is_house()
	if townhall_mode:
		_on_Game3_is_townhall()

########CAJAS DE DIÁLOGO PERSONALIZADAS#####
#Caja de salir.
func _on_ExitConfirmation_confirmed():
	$UI.remove_child(Globals.settings)
	Globals._clear_globals()
	Globals.go_to_scene("res://Scenes/Menu/Menu.tscn")

#Caja de volver a jugar
func _on_ReplayOk_pressed():
	$UI.remove_child(Globals.settings)
	Globals.go_to_scene("res://Scenes/Game3/Game3.tscn")

#Mostrar caja de salir, si no se elige volver a jugar.
func _on_ReplayCancel_pressed():
	exit_confirmation.popup()
	exit_confirmation.get_ok().text="Aceptar"
	exit_confirmation.get_cancel().text="Cancelar"


#Caja de ir a la siguiente fase, en caso de victoria.
func _on_NextSceneOk_pressed():
	#Guardar en Globals.houses_p la posición de cada una de las casas creadas.
	for house in houses.get_children():
		Globals.houses_p.append(house.position)
	#Guardar Globals.townhall_p la posición del centro cívico.
	Globals.townhall_p=townhall_node.get_child(0).position
	#Guardar el índice del ciudadano que fue transformado en jefe.
	var child_index=0
	for citizen in units.get_children():
		if citizen.is_warchief:
			Globals.warchief_index=child_index
			break
		else:
			child_index+=1
			
	#Remover Globals.settings como hijo de la UI.
	$UI.remove_child(Globals.settings)
	
	#Ir a la pantalla de intervalo 3.
	Globals.go_to_scene("res://Scenes/Intermissions/Intermission3.tscn")

#Mostrar la pantalla de configuración, si presionamos el botón settings.
func _on_Settings_pressed():
	Globals.settings.visible=true


func _on_Quit_pressed():
	exit_confirmation.popup()
	exit_confirmation.get_ok().text="Aceptar"
	exit_confirmation.get_cancel().text="cancelar"


func _on_Back_pressed():
	$UI/Base/Rectangle/OptionsMenu.visible=false
