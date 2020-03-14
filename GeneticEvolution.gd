extends Node


class GeneticEvolution:
	var NUM_OF_NODES=2 # Don't change this
	var PROB_CROSS = 0.3
	var PROB_MUTATE = 0.01
	var GENES_TO_MUTATE=2
	var selectionParents=[]
	var crossoverChildren=[]
	var total_size
	func _init(selections:Array,total_nodes_size:int):
		for selection in selections:
			selectionParents.append(selection)
		total_size = total_nodes_size
	func CROSS_OVER(cross_variance=0):
		crossoverChildren=[]
		if selectionParents.size() != NUM_OF_NODES:
			print("invalid parrent array size!!!")
			return false
		
		var bestChild =  selectionParents[0]
		var betterChild = selectionParents[1]	
		var bestSprout=[]

		var childIdx = 0
		for bestChildnode in bestChild:
			randomize()
			if rand_range(0,1) > (PROB_CROSS+cross_variance):
				bestSprout.append(bestChildnode)
			else:
				bestSprout.append(betterChild[childIdx])
			childIdx+=1
		crossoverChildren.append(bestSprout)
		return true
	
	func MUTATION(sprouts,extraMutateProb=0,extraMuateGenes=0):
		var ret_children=[]
		var randWeightIdx
		var child
		var weightSize

		var weightMutateCounter = 0
		var perceptron
		var copiedChild=[]
		for _sprout in range(sprouts):
			child = Array(crossoverChildren[0])
			copiedChild=[]
			for p in child:
				perceptron = p.duplicate(true)
				randomize()
				if rand_range(0,1) > (PROB_MUTATE+extraMutateProb):
					pass
				else:	
					weightSize = perceptron.weights.size()
					weightMutateCounter=0
					while weightMutateCounter < (GENES_TO_MUTATE+extraMuateGenes):
						randomize()
						randWeightIdx = randi() % weightSize
						perceptron.weights[randWeightIdx]+= Global.generateRandom()
						weightMutateCounter+=1
					perceptron.bias += Global.generateRandom()
				copiedChild.append(perceptron)
			ret_children.append(copiedChild)
		return ret_children
		
