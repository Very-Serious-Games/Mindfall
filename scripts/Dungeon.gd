# Archivo: dungeon_generator.gd
extends Node3D

# Cargar las escenas
const SALA_SCENE = preload("res://assets/models/levels/Salaprueba.glb")
const INTER_SCENE = preload("res://assets/models/levels/Interprueba.glb")

# Configuración
const MAX_SALAS = 20
var salas_generadas = 0
var posicion_ocupada = {}

func _ready():
	generar_mazmorra()

func generar_mazmorra():
	# Nodo raíz para la mazmorra
	var nodo_mazmorra = Node3D.new()
	nodo_mazmorra.name = "Mazmorra"
	add_child(nodo_mazmorra)
	
	# Colocar la sala inicial
	var posicion_actual = Vector3.ZERO
	colocar_sala(posicion_actual, nodo_mazmorra)
	
	# Generar nuevas salas
	while salas_generadas < MAX_SALAS:
		# Elegir una posición aleatoria con una sala
		var posibles_intersecciones = posicion_ocupada.keys()
		var posicion_interseccion = posibles_intersecciones[randi() % posibles_intersecciones.size()]
		
		# Colocar intersección y salas alrededor
		colocar_interseccion(posicion_interseccion, nodo_mazmorra)

func colocar_sala(posicion, nodo_mazmorra):
	if posicion_ocupada.has(posicion):
		return  # No colocar si ya está ocupado
	
	var nueva_sala = SALA_SCENE.instance()
	nueva_sala.translation = posicion
	nodo_mazmorra.add_child(nueva_sala)
	posicion_ocupada[posicion] = "sala"
	salas_generadas += 1

func colocar_interseccion(posicion, nodo_mazmorra):
	# Si ya hay una intersección en esta posición, no colocar otra
	if posicion_ocupada.get(posicion) == "interseccion":
		return
	
	var nueva_interseccion = INTER_SCENE.instance()
	nueva_interseccion.translation = posicion
	nodo_mazmorra.add_child(nueva_interseccion)
	posicion_ocupada[posicion] = "interseccion"
	
	# Generar salas alrededor de la intersección
	for offset in [Vector3(10, 0, 0), Vector3(-10, 0, 0), Vector3(0, 0, 10), Vector3(0, 0, -10)]:
		if randi() % 2 == 0 and salas_generadas < MAX_SALAS:
			colocar_sala(posicion + offset, nodo_mazmorra)
