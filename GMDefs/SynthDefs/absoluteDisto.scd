(
var idDict = (
	name: "AbsDist",
	symbol: \gmAbsDist,
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
			scale: 8,
			text: "thresh",
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

SynthDef(\gmAbsDist, { |out = 0, in,
	threshold = 0, pow = 1|

	var snd;
	var pos, posLow, posHigh;
	var neg, negLow, negHigh;

	snd = In.ar(in, 2);

	pos = snd.clip(0, 1);
	posHigh = pos.thresh(threshold);
	posLow = pos - posHigh;
	// /!\ 0.reciprocal = inf
	posLow = posLow *
	min(
		threshold.reciprocal,
		20
	);
	posLow = posLow.pow(pow);
	posLow = posLow * threshold;
	pos = posLow + posHigh;

	neg = snd.neg.clip(0, 1);
	negHigh = neg.thresh(threshold);
	negLow = neg - negHigh;
	// /!\ 0.reciprocal = inf
	negLow = negLow *
	min(
		threshold.reciprocal,
		20
	);
	negLow = negLow.pow(pow);
	negLow = negLow * threshold;
	neg = negLow + negHigh;
	neg = neg.neg;

	snd = pos + neg;

	Out.ar(out, snd);
}).add;

idDict
)