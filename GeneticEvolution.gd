extends Node


class GeneticEvolution:
	var PROB_CROSS = 0.4
	var PROB_MUTATE = 0.1
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
		
		# 8 sensors
#		var c1 = Global.flatArrayOneDepth([selectionParents[0].slice(0,7),selectionParents[1].slice(8,13),selectionParents[1].slice(14,17),selectionParents[0].slice(18,19)])
#		var c2 = Global.flatArrayOneDepth([selectionParents[1].slice(0,7),selectionParents[0].slice(8,13),selectionParents[0].slice(14,17),selectionParents[1].slice(18,19)])
#		
		# 5 sensors
#		var c1 = Global.flatArrayOneDepth([selectionParents[0].slice(0,9),selectionParents[1].slice(10,13)])
#		var c2 = Global.flatArrayOneDepth([selectionParents[0].slice(0,3),selectionParents[1].slice(4,13)])
		var bestChild =  selectionParents[0]
		var betterChild = selectionParents[1]
		
		var bestSprout=[]

		var childIdx = 0
		for bestChildnode in bestChild:
			randomize()
			if rand_range(0,1) > PROB_CROSS:
				bestSprout.append(bestChildnode)
			else:
				bestSprout.append(betterChild[childIdx])
			childIdx+=1
		crossoverChildren.append(bestSprout)
		return true
	
	func MUTATION(sprouts):
		var ret_children=[]
		var randWeightIdx
		var child
		var weightSize
		var GENES_TO_MUTATE=3
		var weightMutateCounter = 0
		var perceptron
		var copiedChild=[]
		for sprout in range(sprouts):
			child = Array(crossoverChildren[0])
			copiedChild=[]
			for p in child:
				perceptron = p.duplicate(true)
				randomize()
				if rand_range(0,1) > PROB_MUTATE:
					pass
				else:	
					weightSize = perceptron.weights.size()
					weightMutateCounter=0
					while weightMutateCounter < GENES_TO_MUTATE:
						randomize()
						randWeightIdx = randi() % weightSize
						perceptron.weights[randWeightIdx]+= Global.generateRandom()
						weightMutateCounter+=1
					perceptron.bias += Global.generateRandom()
				copiedChild.append(perceptron)
			ret_children.append(copiedChild)
		return ret_children
		
