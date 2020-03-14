extends Node

# BEST BOIS LEADERBOARD
var CHAMPION_BOI = [{"bias":0.618385,"weights":[-0.573868,1.387129,-1.010231,0.079342,0.956416,0.675629,-0.790074,-0.424861]},{"bias":1.073194,"weights":[0.121042,0.151521,0.242679,0.166408,-0.456945,-0.678453,-0.13195,0.599788]},{"bias":0.138586,"weights":[-0.77469,0.21323,-0.295174,-0.256281,-0.1687,0.276731,-0.2163,-0.212806]},{"bias":1.84612,"weights":[0.634449,-0.136947,-0.222887,-0.2,-0.119064,0.553128,-0.696003,-0.497247]},{"bias":-0.108726,"weights":[-0.576889,-0.406743,-0.013529,0.237194,0.2,-0,-0.491498,0.1]},{"bias":1.030995,"weights":[-0.198739,-0.540972,0.606304,0.135584,0.501521,0.534172,0.511936,0.061849]},{"bias":0.142012,"weights":[-0.958609,1.141915,0.682431,-0.60588,0.320305,1.360161]},{"bias":0.372984,"weights":[0.159386,0.324181,-0.517982,-0.067903,-1.215673,0.2]},{"bias":-0.458293,"weights":[-0.010791,0.222537,-0.1,-0.198791,0.59363,0.396959]},{"bias":0.307329,"weights":[0.1,0.55783,1.080715,-0.009371,-0.31036,-0.156549]},{"bias":0.413065,"weights":[0.2,0.10043,-1.102759,0.634844]},{"bias":0.104185,"weights":[-0.198564,0.222968,-0.383281,-0.110098]},{"bias":0.289563,"weights":[-0.605125,0.635339,-0.666401,0.088437]},{"bias":0.321561,"weights":[-0.632971,-0.108234,-0.040257]},{"bias":-0.068438,"weights":[0.1,-0.386094,0.186556]}]
# AI CONFIG
var LAYERS_CONFIGURE=[6,4,3,2]  #[8,6,4,2] 
var INTELLIGENCE=1#8: 5; 5 :20
#var VARIANCE= 0.5
var MUTATOR = 0.01
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
