extends Node

# Neuron Network


class Perceptron:
	var bias
	var ACTIVATE_FUNCTION = "tanh"
	var weights=[]
	func _init(prev_layer_nodes:int):
		for _i in range(prev_layer_nodes):
			self.weights.append(Global.randomNumberFeeder(-Global.VARIANCE,Global.VARIANCE))
		self.bias= Global.randomNumberFeeder(-Global.MUTATOR,Global.MUTATOR)
		gene_mutate()
		
	func activate(inputs):
		var output = 0
		for i in inputs.size():
			output+=weights[i]*inputs[i]*Global.LEARNING_RATE
		output = output +bias
		return output 
	
	func gene_mutate():
		randomize()
		for weight in weights:
			weight += rand_range(-Global.MUTATOR,Global.MUTATOR)
		pass
	func generate_bias(_bias):
		bias=_bias
	
	func set_weights(wts):
		weights=wts
		
	func set_bias(b):
		bias=b

class NeuronLayer:
	var perceptrons=[]
	func _init(currentLayerPs,prevLayerPs):
		for _i in range(currentLayerPs):
			perceptrons.append(Perceptron.new(prevLayerPs))
		
	func analyze(inputs:Array):
		var layer_outputs=[]
		for i in range(inputs.size()):
			var p = perceptrons[i]
			layer_outputs.append(p.activate(inputs[i]))
		return layer_outputs


class NeuronNetwork:
	var first_layer_inputs=[]
	var last_layer_outputs=[]
	var NN=[]
	var NNLayersConfig
#	var activated_layer
	func _init(layersConfig,initGenes):
		var Nlayer
		NNLayersConfig=layersConfig
		for i in range(layersConfig.size()):
			var currentLayerNodes = layersConfig[i]
			var prevLayerNodes
			if i == 0:
				prevLayerNodes=8
				for _i in range(currentLayerNodes):
					first_layer_inputs.append(0)
			else:
				prevLayerNodes=layersConfig[i-1]
			if !initGenes:	
				NN.append(NeuronLayer.new(currentLayerNodes,prevLayerNodes))
			else:
			# takes an array of NeuronLayer of Nodes
				var currentLayer = NeuronLayer.new(currentLayerNodes,prevLayerNodes)
				NN.append(currentLayer)
				Nlayer = initGenes[i]
				var ordinal=0
				var currentNode
				for node in Nlayer:
					currentNode = currentLayer.perceptrons[ordinal]
					currentNode.set_weights(node.weights)
					currentNode.gene_mutate()
					currentNode.generate_bias(node.bias)
					ordinal+=1
							
	func extract_genes():
		var genes=[]
		for Nlayer in NN:
			for p in Nlayer.perceptrons:
				genes.append({"weights":p.weights,"bias":p.bias})
		return genes
	
	func set_inputs(inputs):
		if inputs.size() != first_layer_inputs.size():
#			print("invalid input array size!!!")
			return false 
		else:
			first_layer_inputs=inputs
	func get_outputs():
		return last_layer_outputs
	
	func activate_nn():
		var inputs
		var outputs
		var currentLayer
		for layerOrdinal in NN.size():
			currentLayer = NN[layerOrdinal]
			inputs=[]
			
			# Forward Propagation
			if layerOrdinal==0:
				for _i in range(first_layer_inputs.size()):
					inputs.append(first_layer_inputs)
			else:
				for _i in range(NNLayersConfig[layerOrdinal]):
					inputs.append(outputs)
					
			outputs = currentLayer.analyze(inputs)
		last_layer_outputs=outputs
#		print("in ",first_layer_inputs)
#		print("out ",last_layer_outputs)
		return true
	 
