extends TileMapLayer

## Dictionary to store the state of each tile, using the local position as the key
var cell_pressure_data: Dictionary = {}
signal pressure_changed()

## Function to change the pressure of a cell
func set_cell_pressure(cell: Vector2, pressure_change: int) -> void:
	if cell in cell_pressure_data:
		cell_pressure_data[cell] = cell_pressure_data[cell] + pressure_change
	else:
		cell_pressure_data[cell] = pressure_change
	
	pressure_changed.emit()

## Function to get the current pressure of a cell, returns '0' if the cell pressure is not found
func get_tile_health(cell: Vector2) -> int:
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
				set_cell_pressure (cell,5)

			elif event.button_index == MOUSE_BUTTON_LEFT:
				set_cell_pressure (cell,-5)

func _physics_process(delta):
	pass
