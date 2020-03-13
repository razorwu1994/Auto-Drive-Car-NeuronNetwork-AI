extends Node

var LAYERS_CONFIGURE=[8,6,4,2]
var SUPA_LARGE_VALUE=100
var SUPA_SMALL_VALUE=-99999999999999
var LEARNING_RATE=0.8
var VARIANCE= 5
var MUTATOR = 5
var MATH_E = 2.71828
static func randomNumberFeeder(openNum,closeNum):
	randomize()
	return rand_range(openNum,closeNum)

func countNodeSize():
	var sum=0
	for node in LAYERS_CONFIGURE:
		sum += node
	return sum
class CarProgressSorter:
	static func sort_descending(a, b):
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


func sigmoid(t):
	return 1/(1+pow(MATH_E,-1))

