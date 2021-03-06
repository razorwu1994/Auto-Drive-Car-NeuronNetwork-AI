extends Node2D
export (float) var carX = 400.092
export (float) var carY = 2286

export (int) var engine_power = 2000
export (bool) var use_file = false
export (bool) var allow_rough_bestBoi = false
var BEST_PROGRESS=0
var CAR = load("Car.tscn")
var carsGameTree
var generations
var training #training indicator
var turn_angle
var population_size = Global.POPULATION
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
	var trace = $Terrain/GoodBoiGuideLine.curve
	var p =trace.get_closest_offset(trace.get_closest_point(carPos))/trace.get_baked_length()
	return p

func spawn_one_car(node,gene=null):
	var network = NN.NeuronNetwork.new(Global.LAYERS_CONFIGURE,gene)
	carsGameTree.append({"neuronNetwork":network,"progress":0.0,"carNode":node})
	
func check_if_allDead():
	var manualDrive=0 
	if self.has_node("Car"):
		manualDrive=1
	var deadCars = filter(funcref(self,"filterDeadCars"),carsGameTree)
	return deadCars.size() == (carsGameTree.size()-manualDrive)
	
#func set_camera_limits():
#	var map_limits = $TileMap.get_used_rect()
#	var map_cellsize = $TileMap.cell_size
#	$CarTest/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
#	$CarTest/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
#	$CarTest/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
#	$CarTest/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y

func _ready():
	turn_angle = float($CanvasLayer/ControlPanel/ConfigControl/VBoxContainer/turn/Value.text)
	generations=0
	init_cars(init_with_file())
	if self.has_node("Car"):
		if self.get_node("Car").SELF_DRIVING:
			$CanvasLayer/ControlPanel/PanelContainer/ControlCenter/CheckButton.pressed=false
	
func init_cars(genes=[]):
	population_size = int($CanvasLayer/ControlPanel/ConfigControl/VBoxContainer/population/Value.text)
	var gene
	carsGameTree=[]
	if self.has_node("Car"):
		spawn_one_car(self.get_node("Car"),null)
	for i in range(population_size):
		if i < genes.size():
			gene = genes[i]
		else:
			gene = null
		var spawnedCar = CAR.instance()
		spawnedCar.position = Vector2(carX,carY)
		spawnedCar.scale= Vector2(1,1)
		spawnedCar.engine_power = engine_power
		spawnedCar.steering_angle=float($CanvasLayer/ControlPanel/ConfigControl/VBoxContainer/turn/Value.text)
		self.add_child(spawnedCar)
		spawn_one_car(spawnedCar,gene)
		
	training=true
	$CanvasLayer/ControlPanel/Stats/ControlCenter/Generation/HBoxContainer/generation.text=str(generations)

func init_with_file():
	if !use_file:
		return []
	else:
		var file = File.new()
		if not file.file_exists("user://"+Global.BEST_BOI_FPATH+"-"+str(turn_angle)):
			print("No file saved!")
			return
		
		# Open existing file
		if file.open("user://"+Global.BEST_BOI_FPATH+"-"+str(turn_angle), File.READ) != 0:
			print("Error opening file")
			return
		
		# Get the data
		var gene = parse_json(file.get_line())
		var genes = []
		file.close()
		for _c in range(population_size):
			genes.append(Global.translate_genes(gene,Global.LAYERS_CONFIGURE))
		return genes
		
func _physics_process(_delta):
	filterCars()
#	set_camera()
	collectingProbe()
	paintCars()
	checkIfEvolution()
	if !self.has_node('Car')&& $CanvasLayer/ControlPanel/SelfDrive/ControlCenter/CheckButton.pressed:
		$CanvasLayer/ControlPanel/SelfDrive/ControlCenter/CheckButton.pressed=false
	if self.has_node('Car') && !self.get_node('Car').SELF_DRIVING:
		self.get_node('Car').get_node('Camera2D').current=true
		

var COLOR_ARRAY=[Color.red,Color.green]
# UI function
func paintCars():
	carsGameTree.sort_custom(Global.CarProgressSorter,'sort_descending')
	if carsGameTree.size()>0:
		$CanvasLayer/ControlPanel/Stats/ControlCenter/HB/first/progress.text= str("%2.4f" % carsGameTree[0].progress)+"%"
	if carsGameTree.size()>1:
		$CanvasLayer/ControlPanel/Stats/ControlCenter/HB/second/progress.text= str("%2.4f" % carsGameTree[1].progress)+"%"
	var liveCars = filter(funcref(self,"filterLiveCars"),carsGameTree)
	liveCars.sort_custom(Global.CarProgressSorter,'sort_descending')
	if liveCars.size()>0:
		liveCars[0].carNode.get_node('Camera2D').current = true
		$CanvasLayer/ControlPanel/Stats/ControlCenter/speed/stat.text= "%4.1f" % liveCars[0].carNode.velocity.length()
		
		var counter = 0
		while counter < liveCars.size():
			if counter < 2:
				liveCars[counter].carNode.get_node('carSprite').self_modulate=COLOR_ARRAY[counter]
				liveCars[counter].carNode.z_index = 10+ 2-counter
			else:
				liveCars[counter].carNode.get_node('carSprite').self_modulate=Color.white
				liveCars[counter].carNode.z_index = 9
			counter+=1
		
	
# UI function : Filter out dead carsGameTree
func filterCars():
	var _i= 0
	var lives = 0
	for car in carsGameTree:
		car.progress=compute_progress(car.carNode.position)*100
		_i += 1
		var isDead = !car.carNode.live
		if isDead:
			if car.carNode.is_inside_tree():
				self.remove_child(car.carNode)	
		else:
			lives+=1
	$CanvasLayer/ControlPanel/Stats/ControlCenter/Generation/lives/text.text=str(lives)
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
	var carInputs
	for car in carsGameTree:
		if car.carNode.live:
			network=car.neuronNetwork
			carInputs=car.carNode.sensorDistances
			carInputs.append(car.progress*Global.PROGRESS_REWARD_FACTOR)
			network.set_inputs(carInputs)
			if network.activate_nn():
					var command=network.get_outputs()	

					car.carNode.NN_turn=command[0]
					car.carNode.NN_gas=command[1]

var BEST_BOI
var BETTER_BOI
func boiDeterminator():
	var variator=0
	if allow_rough_bestBoi:
		variator=Global.BOI_RANGE
	if carsGameTree.size() > 0:
		if BEST_BOI == null:
			BEST_BOI = carsGameTree[0]
			print("NEW BEST BOIIIII ",BEST_BOI.progress)
		elif carsGameTree[0].progress > (BEST_BOI.progress-variator):
			BEST_BOI = carsGameTree[0]
			print("NEW BEST BOIIIII ",BEST_BOI.progress)
	
	if carsGameTree.size() > 1:
		if BETTER_BOI == null:
			BETTER_BOI = carsGameTree[1]
		else:
			if  carsGameTree[1].progress > ( BETTER_BOI.progress-variator) :
				BETTER_BOI = carsGameTree[1]
			elif carsGameTree[0].progress >( BETTER_BOI.progress-variator):
				BETTER_BOI = carsGameTree[0]

# Functional function : Select 2 best performance parents and give birth to children
func checkIfEvolution():
	if !training: return;
	var ifAllDead = check_if_allDead()
	if ifAllDead:
		training=false
		carsGameTree.sort_custom(Global.CarProgressSorter,'sort_descending')

		boiDeterminator()
		BEST_PROGRESS =  BEST_BOI.progress

		$CanvasLayer/ControlPanel/Stats/ControlCenter/best/stat.text=str(BEST_PROGRESS)+"%"
		var new_cars=[]
		if population_size>1:
			var geAlgo = GE.GeneticEvolution.new([BEST_BOI.neuronNetwork.extract_genes(),BETTER_BOI.neuronNetwork.extract_genes()],Global.countNodeSize())
			var children_genes = []
			# Increase cross prob if best and better are really close
			var cross_variance = BEST_BOI.progress-BETTER_BOI.progress
			if cross_variance < 2:
				cross_variance = 0.1
			else:
				cross_variance=0
			if geAlgo.CROSS_OVER(cross_variance):
				children_genes=geAlgo.MUTATION(population_size,float($CanvasLayer/ControlPanel/ConfigControl/VBoxContainer/passion/Value.text),int(Global.MAX_FIT/BEST_BOI.progress))
			var new_gene=[]
			for gene in children_genes:
				new_gene=Global.translate_genes(gene,Global.LAYERS_CONFIGURE)
				new_cars.append(new_gene)

		init_cars(new_cars)
#		print(carsGameTree[0].neuronNetwork.extract_genes())
		generations+=1
		$CanvasLayer/ControlPanel/Stats/ControlCenter/Generation/HBoxContainer/generation.text=str(generations)

		goodBoys=0




# Signal listener
var goodBoys=0

# Print out and remove success car	
func _on_DashLine_finished(target):
	for i in carsGameTree.size():
		if carsGameTree[i].carNode.get_name() == target.get_name():
			carsGameTree[i].progress = 100
			goodBoys+=1
			$CanvasLayer/ControlPanel/Stats/ControlCenter/goodboi/stat.text=str(goodBoys)
#	print(target.get_name(),' just crossed the line!!!')

# Spawning car when btn is pressed
func _on_ControlPanel_carSpawning():
	var liveCars = filter(funcref(self,"filterLiveCars"),carsGameTree)
	for car in liveCars:
		car.carNode.live=false
		self.remove_child(car.carNode)
	checkIfEvolution()

func _on_ControlPanel_printBestNN():
	if use_file:
		carsGameTree.sort_custom(Global.CarProgressSorter,'sort_descending')
		boiDeterminator()
		# Open a file
		var file = File.new()
		if file.open("user://"+Global.BEST_BOI_FPATH+"-"+str(turn_angle), File.WRITE) != 0:
			print("Error opening file")
			return
		file.store_line(to_json(BEST_BOI.neuronNetwork.extract_genes()))
		file.close()
		print("File saved in "+Global.BEST_BOI_FPATH+"-"+str(turn_angle))
	else:
		print("Enable use_file to use this feature")


func _on_ControlPanel_discardBestBoi():
	BEST_BOI=null
	BETTER_BOI=null
	BEST_PROGRESS=0
	$CanvasLayer/ControlPanel/Stats/ControlCenter/best/stat.text="N/A%"


func _on_ControlPanel_useChampionBoi():
	var liveCars = filter(funcref(self,"filterLiveCars"),carsGameTree)
	for car in liveCars:
		car.carNode.live=false
		self.remove_child(car.carNode)
	var genes = []
	for _p in range(population_size):
		genes.append(Global.translate_genes(Global.CHAMPION_BOI,Global.LAYERS_CONFIGURE))
	init_cars(genes)


func _on_ControlPanel_manualDrive():
	if self.has_node("Car"):
		self.get_node("Car").SELF_DRIVING=false


func _on_ControlPanel_selfDrive():
	if self.has_node("Car"):
		self.get_node("Car").SELF_DRIVING=true

var SHOW_SENSOR = false
func _on_ControlPanel_showSensor():
	SHOW_SENSOR= true


func _on_ControlPanel_hideSensor():
	SHOW_SENSOR=false
