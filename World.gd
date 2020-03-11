extends Node2D
export (float) var carX = 806.06
export (float) var carY = 123
export (int) var population_size = 20
export (int) var engine_power = 2000
var CAR = load("Car.tscn")
var carsGameTree=[]
# Helper functions
func filter(filter_function: FuncRef, candidate_array: Array)->Array:
	var filtered_array := []
	for candidate_value in candidate_array:
		if filter_function.call_func(candidate_value):
			filtered_array.append(candidate_value)
	return filtered_array
	
func filterLiveCars(car):
	return car.carNode.live
func filterDeadCars(car):
	return !car.carNode.live
func filterNotSUPALARGEValues(item):
	return item<Global.SUPA_LARGE_VALUE 
	
func compute_progress(carPos):
	var trace = $Track.curve
	return trace.get_closest_offset(trace.get_closest_point(carPos))/trace.get_baked_length()

func spawn_one_car(node):
	var NN = FNNGEN.NeuronNetwork.new(Global.LAYERS_CONFIGURE,true)
	carsGameTree.append({"neuronNetwork":NN,"progress":0.0,"carNode":node})
#func set_camera_limits():
#	var map_limits = $TileMap.get_used_rect()
#	var map_cellsize = $TileMap.cell_size
#	$CarTest/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
#	$CarTest/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
#	$CarTest/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
#	$CarTest/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y

func _ready():
	randomize()
	init_cars()

	
func init_cars():
	if self.has_node("Car"):
		spawn_one_car(self.get_node("Car"))
	for i in range(population_size):
		var spawnedCar = CAR.instance()
		spawnedCar.position = Vector2(carX,carY)
		spawnedCar.scale= Vector2(1,1)
		spawnedCar.engine_power = engine_power
		self.add_child(spawnedCar)
		spawn_one_car(spawnedCar)
		
func _physics_process(delta):
	filterCars()
	set_camera()
	collectingProbe()
	paintCars()

var COLOR_ARRAY=[Color.red,Color.green]
# UI function
func paintCars():
	var customSorter = Global.CarProgressSorter.new()
	carsGameTree.sort_custom(customSorter,'sort_descending')
	$CanvasLayer/ControlPanel/PanelContainer/VBoxContainer/HBoxContainer/bestProgress.text= str(carsGameTree[0].progress)+"%"
	var counter = 0
	while counter < carsGameTree.size():
		if counter < 2:
			carsGameTree[counter].carNode.get_node('carSprite').self_modulate=COLOR_ARRAY[counter]
		else:
			carsGameTree[counter].carNode.get_node('carSprite').self_modulate=Color.white
		counter+=1

# UI function : Filter out dead carsGameTree
func filterCars():
	var deadCars = []
	var i= 0
	for car in carsGameTree:
		car.progress=compute_progress(car.carNode.position)*100
		i += 1
		var isDead = !car.carNode.live
		if isDead:
			if car.carNode.is_inside_tree():
				self.remove_child(car.carNode)	
	
# UI function: Active camera for player(priority) or random self driving car
func set_camera():
	for child in self.get_children():
		if child is KinematicBody2D:
			if self.has_node("Car")&&!child.SELF_DRIVING||!self.has_node("Car"):
				for c in child.get_children():
					if c is Camera2D:
						c.current = true

# Functional function: Collect inputs for Neuron Network
func collectingProbe():
	var network
	for car in carsGameTree:
		if car.carNode.live:
			network=car.neuronNetwork
			network.set_inputs(car.carNode.sensorDistances)
			if network.activate_nn():
					var command=network.get_outputs()
					if command[0] > -25 && command[0] < 25:
						car.carNode.NN_turn=0
					elif command[0] >=25:
						car.carNode.NN_turn=1
					else:
						car.carNode.NN_turn=-1
					car.carNode.NN_gas=max(0.5,tanh(command[1])+1)


# Signal listener

# Print out and remove success car	
func _on_DashLine_finished(target):
	for i in carsGameTree.size():
		if carsGameTree[i].get_name() == target.get_name():
			self.remove_child(carsGameTree[i])
	print(target.get_name(),' just crossed the line!!!')

# Spawning car when btn is pressed
func _on_ControlPanel_carSpawning():
	var manualDrive=0 
	if self.has_node("Car"):
		manualDrive=1
	var deadCars = filter(funcref(self,"filterDeadCars"),carsGameTree)
	if deadCars.size() == (carsGameTree.size()-manualDrive):
		carsGameTree=[]
		randomize()
		if manualDrive:
			spawn_one_car(self.get_node("Car"))
		for i in range(population_size):
			var spawnedCar = CAR.instance()
			spawnedCar.position = Vector2(carX,carY)
			spawnedCar.scale= Vector2(1,1)
			spawnedCar.engine_power = engine_power
			self.add_child(spawnedCar)
			spawn_one_car(spawnedCar)
	else:
		print('not dead yet')


