(
init: { |self|
	self
},

getSCOuts: { |self, numChannels|
	var indices, names;
	var numOuts;

	numOuts = ~gmDefs[\server]
	.options.numOutputBusChannels;

	numOuts = numOuts -
	(numOuts % numChannels);
	numOuts = numOuts / numChannels;
	numOuts = numOuts.asInteger;

	indices = List.newClear(numOuts);
	names = List.newClear(numOuts);

	numOuts.do({ |index|
		indices[index] = index * numChannels;
		names[index] =
		"SC out " ++ (index * numChannels).asString;
	});

	(
		busses: indices,
		names: names
	)
},

getSCIns: { |self, numChannels|
	var indices, names;
	var numIns;

	numIns = ~gmDefs[\server]
	.options.numInputBusChannels;

	numIns = numIns -
	(numIns % numChannels);
	numIns = numIns / numChannels;
	numIns = numIns.asInteger;

	indices = List.newClear(numIns);
	names = List.newClear(numIns);

	numIns.do({ |index|
		indices[index] = index * numChannels;
		names[index] =
		"SC in " ++ (index * numChannels).asString;
	});

	(
		busses: indices,
		names: names
	)
},

).init