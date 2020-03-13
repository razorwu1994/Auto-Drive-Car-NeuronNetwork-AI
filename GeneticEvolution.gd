extends Node


class GeneticEvolution:
	var NUM_OF_NODES=2
	var selectionParents=[]
	var crossoverChildren=[]
	var total_size
	func _init(selections:Array,total_nodes_size:int):
		for selection in selections:
			selectionParents.append(selection)
		total_size = total_nodes_size
	func CROSS_OVER():
		crossoverChildren=[]
		if selectionParents.size() != NUM_OF_NODES:
			print("invalid parrent array size!!!")
			return false
			
# Save for future generic
#		var partition_size = int(total_size/NUM_OF_NODES)
#		var startIdx
#		var endIdx
#		var selectedParent
#		for cO in range(NUM_OF_NODES):
#			crossoverChildren.append([])
#			for pO in range(NUM_OF_NODES):
#				if cO == 0:
#					startIdx = pO*partition_size
#					endIdx = (pO+1)*partition_size-1
#				else: #cO == 1
#					startIdx = total_size-(pO+1)*partition_size
#					if startIdx <0:
#						startIdx=0
#					endIdx = total_size-pO*partition_size-1
#				selectedParent = selectionParents[pO]
#				crossoverChildren[cO].append(selectedParent.slice(startIdx,endIdx))
#
#			crossoverChildren[cO]= Global.flatArrayOneDepth(crossoverChildren[cO])
		
		var c1 = Global.flatArrayOneDepth([selectionParents[0].slice(0,7),selectionParents[1].slice(8,13),selectionParents[1].slice(14,17),selectionParents[0].slice(18,19)])
		crossoverChildren.append(c1)
		
		var c2 = Global.flatArrayOneDepth([selectionParents[1].slice(0,7),selectionParents[0].slice(8,13),selectionParents[0].slice(14,17),selectionParents[1].slice(18,19)])
		crossoverChildren.append(c2)
			
		return true
	
	func MUTATION(sprouts):
		if crossoverChildren.size() != NUM_OF_NODES:
			return []
		var ret_children=[]
		var randChildIdx
		var child
		var weightSize
		var NODES_TO_MUTATE=1
		var mutateCounter = 0
		for sprout in range(sprouts):
			if sprout< int(sprouts/2):
				child = Array(crossoverChildren[0])
			else:
				child = Array(crossoverChildren[1])
			while mutateCounter < NODES_TO_MUTATE:
				randomize()
				randChildIdx = randi() % child.size()
				weightSize = child[randChildIdx].weights.size()
				for i in range(weightSize):
					randomize()
					child[randChildIdx].weights[i]+= rand_range(-Global.MUTATOR,Global.MUTATOR)
				child[randChildIdx].bias += (randi()%3-1)*Global.MUTATOR
				ret_children.append(child)
				mutateCounter+=1
		return ret_children
		
	
	
#	func PRODUCE(sprouts):
#		var children = []
#		var currentChild
#		for i in int(sprouts/2):
#			currentChild = Array(crossoverChildren[0])
#			for node in currentChild:
#				randomize()
#				node.bias += (randi()%3-1)*Global.MUTATOR
#			children.append(currentChild)
#		for i in (sprouts-int(sprouts/2)):
#			currentChild =Array(crossoverChildren[1])
#			for node in currentChild:
#				randomize()
#				node.bias += (randi()%3-1)*Global.MUTATOR
#			children.append(currentChild)
#		return children
