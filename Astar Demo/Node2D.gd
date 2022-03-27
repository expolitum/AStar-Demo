extends Node2D

onready var NPI = $Nav/Map # Navigation Polygon Instance
	
# Global variables
var start = Vector2(10,10)
var end = Vector2(10,10)
var path = []
var path_points
export var speed = 0.2
onready var obstacle = preload("res://Obstacle.tscn")
onready var navmap = get_node("Nav/Map")
onready var sprite = get_node("Sprite")

func _ready():
	set_process_input(true)
	set_process(true)
	set_obstacle(get_node("Obstacle"))

func _input(event):
	# If left click, go to that point
	if Input.is_action_just_pressed("click"):
		end = event.global_position
	
	# If right click, add obstacle
	if Input.is_action_just_pressed("right_click"):
		var OB = obstacle.instance()
		OB.set_global_position(get_global_mouse_position())
		add_child(OB)
		set_obstacle(OB)

func _process(_delta):
	path = get_node("Nav").get_simple_path(start, end)
	# Update the current amount of points
	path_points = path.size()
	if path_points < 2:
		return
	
	sprite.position = (sprite.global_position + (path[1] - sprite.global_position).normalized() * speed)
	if sprite.global_position.distance_to(end) < speed:
		sprite.set_global_position(end)

	start = sprite.global_position

	# Update the node so the draw() function is called
	update()

# Draw white dots on the path
func _draw():
	for p in path:
		draw_circle(p, 10, Color(1, 1, 1))

# OBject
func set_obstacle(OB):
	print(OB)
	var NP = PoolVector2Array() # New Polygon
	# Get polygon from the object
	var CP = OB.get_node("Poly").get_polygon() # Collision Polygon
	for vector in CP:
		NP.append(vector + OB.position)
	navmap.get_navigation_polygon().add_outline(NP)
	navmap.get_navigation_polygon().make_polygons_from_outlines()
	
	# Refresh the nav mesh
	NPI.enabled = false
	NPI.enabled = true
