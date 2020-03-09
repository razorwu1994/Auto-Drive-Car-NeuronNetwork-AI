extends Node2D

export (float) var carX = 806.06
export (float) var carY = 123
export (int) var population_size = 20
export (int) var engine_power = 2000
var collisionArray = [0,0,0,0,0]
var CAR = load("Car.tscn")
var cars=[]

#func set_camera_limits():
#	var map_limits = $TileMap.get_used_rect()
#	var map_cellsize = $TileMap.cell_size
#	$CarTest/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
#	$CarTest/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
#	$CarTest/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
#	$CarTest/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y

func _ready():
	init_cars()
	
func init_cars():
	if self.has_node("Car"):
		cars.append(self.get_node("Car"))
	for i in range(population_size):
		var spawnedCar = CAR.instance()
		spawnedCar.position = Vector2(carX,carY)
		spawnedCar.scale= Vector2(1,1)
		spawnedCar.engine_power = engine_power
		self.add_child(spawnedCar)
		cars.append(spawnedCar)
		
func set_camera():
	for child in self.get_children():
		if child is KinematicBody2D:
			if self.has_node("Car")&&!child.SELF_DRIVING||!self.has_node("Car"):
				for c in child.get_children():
					if c is Camera2D:
						c.current = true
			
func filter(filter_function: FuncRef, candidate_array: Array)->Array:
	var filtered_array := []
	for candidate_value in candidate_array:
		if filter_function.call_func(candidate_value):
			filtered_array.append(candidate_value)
	return filtered_array
	
static func filterLiveCars(car):
	return car.live
static func filterDeadCars(car):
	return !car.live

func compute_progress(carPos):
	var trace = $Track.curve
	return trace.get_closest_offset(trace.get_closest_point(carPos))/trace.get_baked_length()
	
func filterCars():
#	var liveCars = filter(funcref(self,"filterLiveCars"),cars)
	var deadCars = filter(funcref(self,"filterDeadCars"),cars)
	for deadCar in deadCars:
		if deadCar.is_inside_tree():
			print(deadCar.get_name()," completed ",int(compute_progress(deadCar.position)*100),"%")
			self.remove_child(deadCar)	
	#cars = liveCars

func _on_DashLine_finished(target):
	for i in cars.size():
		if cars[i].get_name() == target.get_name():
			self.remove_child(cars[i])
	print(target.get_name(),' just crossed the line!!!')

func _physics_process(delta):
	filterCars()
	set_camera()
	collectingProbe()

func collectingProbe():
	for car in cars:
		if car.live:
			print(car.sensorDistances)
