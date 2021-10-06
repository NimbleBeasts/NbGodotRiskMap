extends Camera2D

export (int) var camera_speed = 250 
export (int) var camera_margin = 30

var map_size = Vector2(1000,1000)

var camera_zoom = get_zoom()
var camera_movement = Vector2()

const zoom_levels = [1, 1.5, 2, 2.5]
var zoom_level = 2

func setup(map_size):
	self.map_size = map_size

func _ready():
	set_zoom_level(zoom_level)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			zoom_in()
		elif event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			zoom_out()

func _physics_process(delta):
	var speed = camera_speed * zoom_levels[zoom_level]
	
	# Input Keys
	if Input.is_action_pressed("ui_left"):
		camera_movement.x -= speed * delta
	if Input.is_action_pressed("ui_up"):
		camera_movement.y -= speed * delta
	if Input.is_action_pressed("ui_right"):
		camera_movement.x += speed * delta
	if Input.is_action_pressed("ui_down"):
		camera_movement.y += speed * delta
	
	var rec = get_viewport().get_visible_rect()
	var v = get_local_mouse_position() / zoom_levels[zoom_level] + rec.size/2   
	if rec.size.x - v.x <= camera_margin:
		camera_movement.x += speed * delta
	if v.x <= camera_margin:
		camera_movement.x -= speed * delta
	if rec.size.y - v.y <= camera_margin:
		camera_movement.y += speed * delta
	if v.y <= camera_margin:
		camera_movement.y -= speed * delta
	
	position += camera_movement * get_zoom()
	camera_movement = Vector2(0,0)
	collide_borders()

func collide_borders():
	var rec = get_viewport().get_visible_rect()
	var bp = (rec.size / 2) * zoom_levels[zoom_level]
	
	# Right Bottom Corner
	if position.x >  map_size.x/2 - bp.x:
		position.x = map_size.x/2 - bp.x
	if position.y > map_size.y/2 - bp.y:
		position.y = map_size.y/2  - bp.y

	# Left Top Corner
	if position.x < (-map_size.x / 2) + bp.x:
		position.x = (-map_size.x / 2) + bp.x
	if position.y < (-map_size.y / 2) + bp.y:
		position.y = (-map_size.y / 2) + bp.y


	
func set_zoom_level(zoom_level):
	var level = zoom_levels[zoom_level]
	set_zoom(Vector2(level, level))

func zoom_in():
	zoom_level -= 1
	if zoom_level < 0:
		zoom_level = 0
	set_zoom_level(zoom_level)

func zoom_out():
	zoom_level += 1
	if zoom_level >= zoom_levels.size():
		zoom_level -= 1
	set_zoom_level(zoom_level)
