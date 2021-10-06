extends Node2D

const country_scene = preload("res://Src/Map/MapCountry.tscn")

const COLOR_HIGHLIGHT = Color("#6000ff00")
const COLOR_SELECT = Color("#50003aff")


var image_data: Image
var mouse_pos: Vector2 = Vector2()


var scenario_path = "World"
var scenario_data = {}

func scenario_load(world):
	var path_to_file = "res://Scenarios/"+world+"/config.cfg"
	var file = File.new()
	if not file.file_exists(path_to_file):
		return false
		
	file.open(path_to_file, File.READ)
	scenario_data = parse_json(file.get_line())
	file.close()
	return true

func scenario_place_countries(data):
	for country in data.countries:
		var new_country = country_scene.instance()
		new_country.setup(scenario_path, country)
		$CountryHolder.add_child(new_country)
		new_country.position = Vector2(country.pos_x, country.pos_y)


func _ready():
	if scenario_load(scenario_path):
		# Load Images
		$MapPixelRead.texture = load("res://Scenarios/"+scenario_path+"/"+scenario_data.color_map)
		$MapBase.texture = load("res://Scenarios/"+scenario_path+"/"+scenario_data.base_map)
		
		# Place Countries
		scenario_place_countries(scenario_data)
		
		# Process Color Map
		image_data = $MapPixelRead.texture.get_data().duplicate()
		image_data.decompress()
		image_data.lock()

		# Position Countries
		$CountryHolder.position = -image_data.get_size()/2
		
		# Setup Camera
		$Camera2D.setup(image_data.get_size())
	else:
		print("Error: Couldnt load scenario")
	


func _physics_process(delta):
	mouse_pos = get_global_mouse_position() 
	$Hud/Panel/Label.set_text(str(mouse_pos))
	
	$Hud/FPS.set_text("FPS: " + str(Engine.get_frames_per_second()))
	
	if image_data:
		if mouse_pos.x > 0 and mouse_pos.y > 0:
			var size = image_data.get_size()
			if mouse_pos.x < size.x and mouse_pos.y < size.y:
				var color = image_data.get_pixelv(mouse_pos).to_html(false)
				$Hud/Panel/Label3.set_text(str(color))
				var click_id = int(color.left(2))
				$Hud/Panel/Label2.set_text(str(click_id))

		

func _on_ValidMouseClickOverlay_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			mouse_pos = get_global_mouse_position().ceil() + image_data.get_size()/2
			var color = image_data.get_pixelv(mouse_pos).to_html(false)
			var click_id = color.left(2)
			click_id = ("0x"+click_id).hex_to_int()

			if event.pressed:
				pass
			else:
				if click_id - 1 <= scenario_data.countries.size():
					Events.emit_signal("map_select_country", click_id, COLOR_SELECT, true)



func _on_Button_button_up():
	Events.emit_signal("map_highlight_countries", 9, COLOR_HIGHLIGHT)
	Events.emit_signal("map_highlight_countries", 10, COLOR_HIGHLIGHT)
	Events.emit_signal("map_highlight_countries", 11, COLOR_HIGHLIGHT)
	Events.emit_signal("map_highlight_countries", 12, COLOR_HIGHLIGHT)
	Events.emit_signal("map_highlight_countries", 13, COLOR_HIGHLIGHT)
	Events.emit_signal("map_highlight_countries", 14, COLOR_HIGHLIGHT)



