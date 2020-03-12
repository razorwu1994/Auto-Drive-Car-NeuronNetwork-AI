extends Node


class GeneticEvolution:
	var BREED
	var NUM_OF_NODES=2
	var selectionParents=[]
	var crossoverChildren=[]
	var total_size
	func _init(selections:Array,breed:int):
		for selection in selections:
			selectionParents.append(selection)
		total_size = selectionParents[0].size()
		BREED=breed
		
	func CROSS_OVER():
		crossoverChildren=[]
		if selectionParents.size() != NUM_OF_NODES:
			return false
			
		var partition_size = int(total_size/NUM_OF_NODES)
		var startIdx
		var endIdx
		var selectedParent
		for cO in range(NUM_OF_NODES):
			crossoverChildren.append([])
			for pO in range(NUM_OF_NODES):
				if cO == 0:
					startIdx = pO*partition_size
					endIdx = (pO+1)*partition_size
				else: #cO == 1
					startIdx = total_size-(pO+1)*partition_size
					if startIdx <0:
						startIdx=0
					endIdx = total_size-pO*partition_size
				selectedParent = selectionParents[pO]
				crossoverChildren[cO].append(selectedParent.slice(startIdx,endIdx,NUM_OF_NODES))
				
			crossoverChildren[cO]= Global.flatArrayOneDepth(crossoverChildren[cO])
			if crossoverChildren[cO].size() > total_size:
					crossoverChildren[cO].pop_back()

			
		return true
	
	func MUTATION():
		if crossoverChildren.size() != NUM_OF_NODES:
			return false
		
		for child in crossoverChildren:
			randomize()
			child.shuffle()
			child[0] += rand_range(-Global.MUTATOR,Global.MUTATOR)
	
	func PRODUCE(sprouts):
		var children = []
		for i in int(sprouts/2):
			children.append(crossoverChildren[0])
		for i in (sprouts-int(sprouts/2)):
			children.append(crossoverChildren[1])
			
		return children
