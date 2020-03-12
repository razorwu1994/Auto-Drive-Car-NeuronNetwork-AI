extends Node

var LAYERS_CONFIGURE=[8,6,4,2]
var SUPA_LARGE_VALUE=1000000000000
var SUPA_SMALL_VALUE=-99999999999999
var VARIANCE=5
var RANGE = 5
var MUTATOR = 0.5
func randomNumberFeeder(openNum,closeNum):
	randomize()
	return rand_range(openNum,closeNum)
		
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
