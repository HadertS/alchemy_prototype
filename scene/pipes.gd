extends TileMapLayer

@export var pressure_view_mode = false

## Dictionary to store the state of each tile, using the local position as the key
var cell_pressure_data: Dictionary = {}
signal pressure_changed()

func _ready():
	redraw_pressure_overlay()


func redraw_pressure_overlay():
	get_tree().call_group("pressure_overlay", "queue_free") 
	if pressure_view_mode:
		for cell in get_used_cells():
			var pressure_label = Label.new()
			pressure_label.add_to_group("pressure_overlay")
			pressure_label.size = Vector2(32,32)
			pressure_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
			pressure_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
			pressure_label.text = "%s" % get_tile_pressure(cell)			
			pressure_label.position = map_to_local(cell)-pressure_label.size/2
			add_child(pressure_label)

## Function to change the pressure of a cell
func change_cell_pressure(cell: Vector2, pressure_change: int) -> void:
	if cell in cell_pressure_data:
		cell_pressure_data[cell] = cell_pressure_data[cell] + pressure_change
	else:
		cell_pressure_data[cell] = pressure_change
	
	pressure_changed.emit()
	redraw_pressure_overlay()

## Function to get the current pressure of a cell, returns '0' if the cell pressure is not found
func get_tile_pressure(cell: Vector2) -> int:
	if cell in cell_pressure_data:
		return cell_pressure_data[cell]
	else:
		return 0  # Return 0 if the cell pressure is not found

## Function to check if pressure data exists for a cell
func is_cell_pressure_exist(cell: Vector2) -> bool:
	return cell in cell_pressure_data

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var cell = local_to_map(get_local_mouse_position())
		if cell:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				change_cell_pressure (cell,5)

			elif event.button_index == MOUSE_BUTTON_LEFT:
				change_cell_pressure (cell,-5)

func _physics_process(delta):
	pass
