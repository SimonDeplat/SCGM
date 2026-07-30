(
var idDict = (
	name: "Fixed Convolver",
	symbol: \gmFixedConvolver,
	category: \effect,
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
			symbol: \amp,
			default: 0.1,
			min: 0,
			max: 1,
			scale: \exp,
			text: "amp",
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
			symbol: \mix,
			default: 0.1,
			min: 0,
			max: 1,
			scale: \lin,
			text: "mix",
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
			modStep2: 2,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				((value * 100).asInteger.asString ++ " %")
			},
		),

		(
			type: \kernel,
			symbol: \kernel,
			channels: 1,
			size: 8192,
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	]
);

SynthDef(\gmFixedConvolver, { |out = 0, amp = 1, in,
	mix = 1,
	kernel, kernelSize = 8192, kernelUpdate = 0|
	var snd, effect, resp;
	snd = In.ar(in, 2);
	effect = Convolution2.ar(
		snd,
		kernel,
		kernelUpdate,
		kernelSize,
		amp
	);
	snd = snd * (1 - mix);
	effect = effect * mix;
	snd = snd + effect;
	snd = Limiter.ar(snd);
	Out.ar(out, snd);
}).add;

idDict
)