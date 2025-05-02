extends CharacterBody2D

var movement_speed: float = 200.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var contents
var temperature
var size
var density
var state
 

 
func _ready() -> void:

	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

	# temperature = 100
	# if temperature > 100:
	# 	state = "gas"
	# elif temperature == 0:
	# 	state = "liquid"
	# else:
	# 	state = "solid"
	# if temperature > 0:
	# 	velocity.y = -100
	# else:
	# 	velocity.y = 100
	var pipes = get_node("../Pipes")
	pipes.connect("pressure_changed", _on_pipes_pressure_changed)

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	#set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
	
func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()
	# check temp - if not heated, cool
	# adjust velocity - if hot rise else sink

func reassess_target():
	var cell_with_lowest_pressure
	var current_lowest_pressure = 0 
	for cell in get_node("../Pipes").cell_pressure_data:
		if current_lowest_pressure > get_node("../Pipes").cell_pressure_data[cell]:
			cell_with_lowest_pressure = cell
			current_lowest_pressure = get_node("../Pipes").cell_pressure_data[cell]
	if cell_with_lowest_pressure != null:
		var local = get_node("../Pipes").map_to_local(cell_with_lowest_pressure)
		var global = get_node("../Pipes").to_global(local)
		set_movement_target(global)

func _on_pipes_pressure_changed():
	reassess_target()
	
