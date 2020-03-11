extends Node

var LAYERS_CONFIGURE=[8,7,6,2]
var SUPA_LARGE_VALUE=1000000000000
var SUPA_SMALL_VALUE=-99999999999999
var VARIANCE=5


class CarProgressSorter:
	static func sort_descending(a, b):
		if a.progress > b.progress:
			return true
		return false

