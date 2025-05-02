extends TileMapLayer

@export var pressure_view_mode = false

## Dictionary to store the state of each tile, using the local position as the key
var cell_pressure_data: Dictionary = {}

signal pressure_changed()

var pressure_equalization_running = false

func _ready():
	redraw_pressure_overlay()
	connect("pressure_changed", redraw_pressure_overlay)

func redraw_pressure_overlay():
	get_tree().call_group("pressure_overlay", "queue_free")
	if pressure_view_mode:
		for cell in get_used_cells():
			var pressure_label = Label.new()
			pressure_label.add_to_group("pressure_overlay")
			pressure_label.size = Vector2(32, 32)
			pressure_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			pressure_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			pressure_label.text = "%s" % get_cell_pressure(cell)
			pressure_label.position = map_to_local(cell) - pressure_label.size / 2
			pressure_label.pivot_offset = pressure_label.size / 2
			pressure_label.scale = Vector2(0.75, 0.75)
			add_child(pressure_label)

## Function to change the pressure of a cell
func change_cell_pressure(cell: Vector2i, pressure_change: int) -> void:
	print("changed - ",cell)
	if cell in cell_pressure_data:
		if (cell_pressure_data[cell] + pressure_change)!=0:
			cell_pressure_data[cell] = cell_pressure_data[cell] + pressure_change
		else:
			cell_pressure_data.erase(cell)
		pressure_changed.emit()

	else:	
		if pressure_change != 0:
			cell_pressure_data[cell] = pressure_change
			pressure_changed.emit()

	

## Function to get the current pressure of a cell, returns '0' if the cell pressure is not found
func get_cell_pressure(cell: Vector2i) -> int:
	if cell in cell_pressure_data:
		return cell_pressure_data[cell]
	else:
		return 0 # Return 0 if the cell pressure is not found

## Function to set the pressure of a cell
func set_cell_pressure(cell: Vector2i, new_pressure: int) -> void:
	if new_pressure == 0:
		cell_pressure_data.erase(cell)
	else:
		cell_pressure_data[cell] = new_pressure

## Function to check if pressure data exists for a cell
func is_cell_pressure_exist(cell: Vector2i) -> bool:
	return cell in cell_pressure_data

# Function to equalize pressure once
func pressure_equalization():
	pressure_equalization_running = true
	var temp_pressure_data:Dictionary = cell_pressure_data.duplicate()
	print("OG -",cell_pressure_data)
	for cell in temp_pressure_data:
		var total_pressure = temp_pressure_data[cell]
		var total_cells = 1
		for surrounding in get_surrounding_cells(cell):
			if surrounding in get_used_cells():
				if surrounding in temp_pressure_data:
					total_pressure = total_pressure + temp_pressure_data[surrounding]
				total_cells += 1
		var equalized_pressure = total_pressure / total_cells
		set_cell_pressure(cell,equalized_pressure)
		
		for surrounding in get_surrounding_cells(cell):
		
			if surrounding in get_used_cells():
				set_cell_pressure(surrounding,equalized_pressure)

	print("temp ",temp_pressure_data)
	print("OG -",cell_pressure_data)

	pressure_equalization_running = false
				

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var cell = local_to_map(get_local_mouse_position())
		if cell:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				change_cell_pressure(cell, 500)

			elif event.button_index == MOUSE_BUTTON_LEFT:
				change_cell_pressure(cell, -500)

func _process(_delta):
	if Engine.get_process_frames() % 5 == 0:
		if !pressure_equalization_running:
			pressure_equalization()
			pressure_changed.emit()
	pass # Run expensive logic only once every 5 process (render) frames here.
