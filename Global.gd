extends Node

var LAYERS_CONFIGURE=[6,4,3,2]  #[8,6,4,2] 
var SUPA_LARGE_VALUE=250 
var SUPA_SMALL_VALUE=-99999999999999
var INTELLIGENCE=1#8: 5; 5 :20
var VARIANCE= 0.5
var MUTATOR = 0.5
var MATH_E = 2.71828
var BEST_BOI_FPATH = "best_boi.sav"
var BOI_RANGE=0.01
var PROGRESS_REWARD_FACTOR = 5
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
