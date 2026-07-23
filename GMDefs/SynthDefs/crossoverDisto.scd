(
var idDict = (
	name: "CrossDist",
	symbol: \gmCrossDist,
	category: \distortion,
	type: \effect,
	emission: \continuous,
	group: \filter,
	tunable: false,
	dependencies: nil,

	params: [

		(
			type: \in,
			symbol: \in,
			numChannels: 2,
			text: "in",
		),

		(
			type: \continuous,
			symbol: \threshold,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "%",
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: false,
			helpersStyle: \line,
			centerHelpers: false,
			helpersRatio: 0.333,
			helpersNumber: 3,
			helperSubdivisions: 4,
			// Mod Steps
			modStep: 0.01,
			modStepOperator: \add,
			modStep2: 1.1,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.round(1);
				value = value.asInteger;
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \continuous,
			symbol: \pow,
			default: 1,
			min: 1,
			max: 32,
			scale: \exp,
			text: "power",
			polarity: \uni,
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),

	]
);

SynthDef(\gmCrossDist, { |out = 0, in,
	threshold = 0, pow = 1|

	var snd;
	var amplitude, currentThreshold;
	var pos, posLow, posHigh;
	var neg, negLow, negHigh;

	snd = In.ar(in, 2);
	amplitude = Amplitude.ar(
		snd,
		0.01,
		0.05
	);

	currentThreshold = amplitude * threshold;

	pos = snd.clip(0, 1);
	posHigh = pos.thresh(currentThreshold);
	posLow = pos - posHigh;
	// /!\ 0.reciprocal = inf
	posLow = posLow *
	min(
		currentThreshold.reciprocal,
		20
	);
	posLow = posLow.pow(pow);
	posLow = posLow * currentThreshold;
	pos = posLow + posHigh;

	neg = snd.neg.clip(0, 1);
	negHigh = neg.thresh(currentThreshold);
	negLow = neg - negHigh;
	// /!\ 0.reciprocal = inf
	negLow = negLow *
	min(
		currentThreshold.reciprocal,
		20
	);
	negLow = negLow.pow(pow);
	negLow = negLow * currentThreshold;
	neg = negLow + negHigh;
	neg = neg.neg;

	snd = pos + neg;

	Out.ar(out, snd);
}).add;

idDict
)