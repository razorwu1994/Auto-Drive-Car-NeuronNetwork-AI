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
			self.weights.append(randomNumberFeeder(-Global.VARIANCE,Global.VARIANCE))
			self.bias= randomNumberFeeder(-Global.VARIANCE,Global.VARIANCE)
			
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
	
	func randomNumberFeeder(openNum,closeNum):
		return rand_range(openNum,closeNum)

	func set_weights(weights):
		self.weights=weights
		
	func set_bias(bias):
		self.bias=bias

class NeuronLayer:
	var perceptrons=[]
	func _init(currentLayerPs,nextLayerPs):
		for i in range(currentLayerPs):
			perceptrons.append(Perceptron.new(nextLayerPs))
	
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
	func _init(layersConfig,isLayerConfig):
#		activated_layer=0
		if isLayerConfig:
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
					
				NN.append(NeuronLayer.new(currentLayerNodes,nextLayerNodes))
	
	func print_genes():
		var genes=[]
		for Nlayer in NN:
			for p in Nlayer.perceptrons:
				genes.append({"weights":p.weights,"bias":p.bias})
#				print("weights: ", p.weights," bias: ",p.bias)
	
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
