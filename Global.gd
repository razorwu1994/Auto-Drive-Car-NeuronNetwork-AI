extends Node

# BEST BOIS LEADERBOARD
var CHAMPION_BOI = [{"bias":0.865823,"weights":[-0.306356,0.354296,-0.117402,-0.1,0.461795,0.2426,-0.450329,-0.325927]},{"bias":0.670518,"weights":[0.126504,0.365988,0.301064,0.471112,-0.456945,-0.291119,-0.359316,0.370083]},{"bias":0.27371,"weights":[-0.187968,0.21323,-0.295174,-0.156281,-0.2687,0.469097,-0.2163,-0.212806]},{"bias":0.848107,"weights":[0.431774,-0.136947,0.063843,-0.2,-0.19377,0.266043,-0.647284,-0.307788]},{"bias":-0.208726,"weights":[-0.476889,-0.406743,-0.013529,0.237194,0.1,0.1,-0.491498,0.1]},{"bias":0.834144,"weights":[-0.1,-0.540972,0.492751,-0.340506,0.287518,0.580358,0.1,-0.008]},{"bias":-0.515216,"weights":[-0.276711,0.163894,0.160903,-0.246063,0.377211,0.1]},{"bias":0,"weights":[0.314848,0.324181,-0.1,-0.142184,-0.556309,0.1]},{"bias":-0.458293,"weights":[-0.010791,0.222537,-0.1,-0.198791,0.59363,0.396959]},{"bias":1.047772,"weights":[0.1,0.460252,0.729741,0.143857,-0.11036,-0.156549]},{"bias":0.290174,"weights":[0.1,0.20043,-0.715339,0.337179]},{"bias":0.104185,"weights":[-0.198564,0.222968,-0.383281,-0.110098]},{"bias":0.403857,"weights":[0.1,0.495581,-0.301994,-0.011563]},{"bias":0.221561,"weights":[-0.432971,-0.108234,-0.140257]},{"bias":-0.068438,"weights":[0.1,-0.386094,0.186556]}]

# AI CONFIG
var LAYERS_CONFIGURE=[6,4,3,2]  #[8,6,4,2] 
var INTELLIGENCE=1#8: 5; 5 :20
#var VARIANCE= 0.5
var MUTATOR = 0.1
var MAX_FIT = 100
# MATH
var MATH_E = 2.71828
var SUPA_LARGE_VALUE=250 
var SUPA_SMALL_VALUE=-99999999999999

# CONTROL FACTOR
var BOI_RANGE=3
var PROGRESS_REWARD_FACTOR = 5

# FILE I/O
var BEST_BOI_FPATH = "best_boi.sav"

# SENSOR
var SENSOR_SAFE_DISTANCE=20
var SENSOR_TOLERANCE_OFFSET = 4

func countNodeSize():
	var sum=0
	for node in LAYERS_CONFIGURE:
		sum += node
	return sum
class CarProgressSorter:
	static func sort_descending(a, b):
		if !a.carNode.SELF_DRIVING:
			return false
		if a.progress > b.progress:
			return true
		return false

static func flatArrayOneDepth(array:Array):
	var temp =[]
	for subArr in array:
		for item in subArr:
			temp.append(item)
	return temp

func translate_genes(gene:Array,layersConfig):
		var _NN=[]
		var layerCounter = 0
		var netLayer=[]
		var geneIdx = 0
		for layerNodes in layersConfig: #[8,6,4,2]
			layerCounter = 0
			netLayer=[]
			while layerCounter<layerNodes:
				netLayer.append(gene[geneIdx+layerCounter])
				layerCounter+=1
			_NN.append(netLayer)
			geneIdx += layerNodes
		return _NN	


func revised_sigmoid(t):
	var RANGE_ADJUST = 0.5
	var thick_boi = 1/(1+float(pow(MATH_E,-t)))-RANGE_ADJUST
	if thick_boi == 0:
		randomize()
		var rand = randi()%2
		if rand == 0:
			thick_boi += MUTATOR * 1
		else:
			thick_boi += MUTATOR * -1
	return float("%2.30f" % thick_boi)

func sigmoid(t):
	return 1/(1+float(pow(MATH_E,-t)))

var MIN_RAND = 0.1
func generateRandom():
	randomize()
	var rand = rand_range(-MUTATOR,MUTATOR)
	return max(abs(rand),MIN_RAND)*sign(rand)

func printToFile(data,path):
	var file = File.new()
	if file.open("user://"+path, File.WRITE) != 0:
		print("Error opening file")
		return
	file.store_line(to_json(data))
	file.close()
