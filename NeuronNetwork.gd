extends Node

# Neuron Network

class Perceptron:
	var out_value
	var bias
	var ACTIVATE_FUNCTION = "tanh"
	var weights=[]
	var activated=false
	func _init(next_layer_nodes:int):
		for i in range(next_layer_nodes):
			self.weights.append(Global.randomNumberFeeder(-Global.VARIANCE,Global.VARIANCE))
			self.bias= Global.randomNumberFeeder(-Global.VARIANCE,Global.VARIANCE)
		gene_mutate()
		
	func activate(in_value):
		out_value = tanh(in_value)+bias
		activated=true
		
	func collect_outputs():
		if activated:
			var outputs=[]
			for w in weights:
				outputs.append(w*out_value)
			activated = false
			return outputs
		else:
			return []
	
	func gene_mutate():
		randomize()
		weights.shuffle()
		for weight in weights:
			weight += rand_range(-Global.MUTATOR,Global.MUTATOR)
	
	func bias_mutate():
		randomize()
		bias=rand_range(-Global.VARIANCE,Global.VARIANCE)
		
	func set_weights(weights):
		self.weights=weights
		
	func set_bias(bias):
		self.bias=bias

class NeuronLayer:
	var perceptrons=[]
	func _init(currentLayerPs,nextLayerPs):
		for i in range(currentLayerPs):
			perceptrons.append(Perceptron.new(nextLayerPs))
		randomize()
		perceptrons.shuffle()
		
	func analyze(inputs):
		if inputs.size() != perceptrons.size():
			return []
		var layer_outputs=[]
		for i in range(inputs.size()):
			var p = perceptrons[i]
			p.activate(inputs[i])
			layer_outputs.append(p.collect_outputs())
		return layer_outputs


class NeuronNetwork:
	var first_layer_inputs=[]
	var last_layer_outputs=[]
	var NN=[]
	var NNLayersConfig
#	var activated_layer
	func _init(layersConfig,initGenes):
#		activated_layer=0
		NNLayersConfig=layersConfig
		for i in range(layersConfig.size()):
			var currentLayerNodes = layersConfig[i]
			var nextLayerNodes

			if i == layersConfig.size()-1:
				nextLayerNodes=0
				for i in range(currentLayerNodes):
					last_layer_outputs.append(0)
			else:
				if i == 0:
					for i in range(currentLayerNodes):
						first_layer_inputs.append(0)
				nextLayerNodes=layersConfig[i+1]
			if !initGenes:	
				NN.append(NeuronLayer.new(currentLayerNodes,nextLayerNodes))
			else:
			# takes an array of NeuronLayer of Nodes
				var currentLayer = NeuronLayer.new(currentLayerNodes,nextLayerNodes)
				for Nlayer in initGenes:
					NN.append(currentLayer)
					var ordinal=0
					var currentNode
					for node in Nlayer:
						currentNode = currentLayer.perceptrons[ordinal]
						currentNode.set_weights(node.weights)
						currentNode.set_bias(node.bias)
						
						
	func print_genes():
		var genes=[]
		for Nlayer in NN:
			for p in Nlayer.perceptrons:
				genes.append({"weights":p.weights,"bias":p.bias})
		return genes
	
	func set_inputs(inputs):
		if inputs.size() != first_layer_inputs.size():
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
			if layerOrdinal==0:
				inputs=first_layer_inputs
			else:
				for i in range(NNLayersConfig[layerOrdinal]):
					inputs.append(0)
				for outputFromOneNode in outputs:
					for i in range(outputFromOneNode.size()):
						inputs[i]+=outputFromOneNode[i]
			if layerOrdinal+1 < NN.size():
				outputs = currentLayer.analyze(inputs)
			else:
				break;
		
		last_layer_outputs=inputs
		return true
	 
