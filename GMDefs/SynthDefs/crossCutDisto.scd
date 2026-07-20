(
var idDict = (
	name: "CrossCutDist",
	symbol: \gmCrossCutDist,
	category: \distortion,
	type: \effect,
	emission: \continuous,
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
			symbol: \preAmp,
			default: 1,
			min: 0,
			max: 3,
			scale: \lin,
			text: "preAmp",
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
				(value.ampdb.trunc(0.01).asString ++ " db")
			},
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
			symbol: \postAmp,
			default: 1,
			min: 0,
			max: 3,
			scale: \lin,
			text: "postAmp",
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
				(value.ampdb.trunc(0.01).asString ++ " db")
			},
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),

	]
);

SynthDef(\gmCrossCutDist, { |out = 0, in,
	threshold = 0, preAmp = 1, postAmp = 1|

	var snd, pos, neg;

	snd = In.ar(in, 2);

	snd = snd * preAmp;

	pos = snd.clip(threshold, 1);
	pos = pos - threshold;

	neg = snd.clip(-1, threshold.neg);
	neg = neg + threshold;

	snd = pos + neg;

	snd = snd * min(
		(1 - threshold).reciprocal,
		0.05.reciprocal
	);

	snd = snd * postAmp;

	Out.ar(out, snd);
}).add;

idDict
)