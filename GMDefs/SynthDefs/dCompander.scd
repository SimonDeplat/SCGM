(
var idDict = (
	name: "DCompander",
	symbol: \gmDCompander,
	category: \dynamics,
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
			default: 1,
			min: 0,
			max: 3,
			scale: \lin,
			text: "threshold",
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
			symbol: \ratio,
			default: 1,
			min: 1,
			max: 16,
			scale: \exp,
			text: "ratio",
			modSteps: [0.01, 0.001],
		),

		(
			type: \continuous,
			symbol: \atk,
			default: 0.01,
			min: 0.001,
			max: 1,
			scale: \exp,
			text: "atk",
			modSteps: [0.01, 0.001],
			// DisplayFunc
			displayFunction: { |value|
				if(value < 0.1) {
					value = value * 1000;
					value = value.asInteger;
					value = value.asString ++ "ms";
				} {
					value = value.trunc(0.01);
					value = value.asString ++ "s";
				};
				value
			},
		),

		(
			type: \continuous,
			symbol: \rel,
			default: 0.1,
			min: 0.01,
			max: 2,
			scale: \exp,
			text: "rel",
			modSteps: [0.01, 0.001],
			// DisplayFunc
			displayFunction: { |value|
				if(value < 0.1) {
					value = value * 1000;
					value = value.asInteger;
					value = value.asString ++ "ms";
				} {
					value = value.trunc(0.01);
					value = value.asString ++ "s";
				};
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

SynthDef(\gmDCompander, { |out = 0, in,
	threshold = 1, ratio = 1, atk = 0.01, rel = 0.1, postAmp = 1|
	var snd = In.ar(in, 2);
	snd = Compander.ar(
		snd,
		snd,
		threshold,
		1.0,
		1 / ratio,
		atk,
		rel
	);
	snd = snd * postAmp;
	Out.ar(out, snd);
}).add;

idDict
)