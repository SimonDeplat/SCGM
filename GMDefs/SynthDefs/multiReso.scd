(
var idDict = (
	name: "MultiReso",
	symbol: \gmMultiReso,
	category: \filter,
	type: \effect,
	emission: \continuous,
	group: \filter,
	tunable: true,
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
			default: 0.75,
			min: 0,
			max: 1,
			scale: \lin,
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
			type: \multiContinuous,
			symbol: \amps,
			default: Array.fill(9, { |i| 1 / (i + 1) }),
			min: 0,
			max: 1,
			scale: 6,
			text: "amps",
			modSteps: [0.01, 0.001]
		),

		(
			type: \multiContinuous,
			symbol: \feedbacks,
			default: Array.fill(9, { 0 }),
			min: 0,
			max: 1,
			scale: \log,
			text: "feedbacks",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \dryWet,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "dryWet",
			modSteps: [0.01, 0.001]
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 0.5,
			values: [8, 4, 2, 1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2", "/4", "/8"],
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	]
);

SynthDef(\gmMultiReso, { |out = 0, in, amp = 1,
	freq = 440, freqMul = 0.25, dryWet = 0|

	var snd, effect;

	var local;

	var channels = Array.fill(9 * 2, { Silent.ar });
	var stereoChannels = Array.fill(9, { nil });
	var feedbackChannels = Array.fill(9 * 2, { Silent.ar });

	var amps = NamedControl.kr(
		\amps,
		[1, 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8, 1/9]
	);

	var feedbacks = NamedControl.kr(
		\feedbacks,
		[0, 0, 0, 0, 0, 0, 0, 0, 0]
	);


	snd = In.ar(in, 2);

	// Get feedback
	local = LocalIn.ar(18);

	// Calculate resonance harmonics
	9.do({ |index|

		// FIX ME: INVERT PHASES LIKE NORMAL SAWTOOTH

		// Left
		channels[index * 2] =
		snd[0]
		+ local[index * 2];

		feedbackChannels[index * 2] = DelayC.ar(
			channels[index * 2],
			0.2,
			(freq * freqMul * (index + 1)).reciprocal - ControlRate.ir.reciprocal,
			feedbacks[index]
		);

		// Right
		channels[index * 2 + 1] =
		snd[1]
		+ local[index * 2 + 1];

		feedbackChannels[index * 2 + 1] = DelayC.ar(
			channels[index * 2 + 1],
			0.2,
			(freq * freqMul * (index + 1)).reciprocal - ControlRate.ir.reciprocal,
			feedbacks[index]
		);

	});

	// Send feedback
	LocalOut.ar(feedbackChannels);

	9.do({ |index|
		stereoChannels[index] =
		[feedbackChannels[index], feedbackChannels[index + 1]] * amps[index];
	});

	effect = Mix.ar(stereoChannels);

	// Mix
	snd = snd * (1 - dryWet);
	effect = effect * dryWet;
	snd = snd + effect;

	// Synth Master
	snd = snd * amp;

	Out.ar(out, snd);
}).add;

idDict
)