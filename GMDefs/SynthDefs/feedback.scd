(
var idDict = (
	name: "Feedback",
	symbol: \gmFeeback,
	category: \misc,
	type: \effect,
	emission: \continuous,
	tunable: false,
	dependencies: nil,
	numChannels: 2,

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
			default: 1,
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
			type: \continuous,
			symbol: \amount,
			default: 0.7,
			min: 0.01,
			max: 0.999,
			scale: \log,
			text: "amount",
			modSteps: [0.1, 0.01],
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.trunc(0.1);
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		// Do not modify min delay without modifying
		// the SynthDef (DelayC.ar(effect, 1 / maxDelay, ... )
		// Also, DelayC min delay should be at least (SampleDur.ir * 4)
		// so at 48k Hz, 12K is the max frequency delay allowed

		(
			type: \continuous,
			symbol: \fDelay,
			default: 1,
			min: 0.5,
			max: 12000,
			scale: \exp,
			text: "fDelay",
			modSteps: [100, 0.5],
			// DisplayFunc
			displayFunction: { |value|
				value = value.asInteger;
				value = value.asString ++ "hz";
				value
			},
		),

		(
			type: \continuous,
			symbol: \dryWet,
			default: 0.5,
			min: 0,
			max: 1,
			scale: \lin,
			text: "dryWet",
			modSteps: [0.01, 0.001],
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
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),

	]
);

SynthDef(\gmFeeback, { |out = 0, in, amp = 1,
	dryWet = 0.5, amount = 0.5, fDelay = 0.1|

	var snd, effect, local;

	snd = In.ar(in, 2);

	local = LocalIn.ar(2);

	effect = Mix.ar([snd, local]);

	// Update max if needed
	effect = DelayC.ar(effect, 2.0,
		((1 / fDelay) - ControlRate.ir.reciprocal)
		.clip((SampleDur.ir * 4), 2)
	);

	LocalOut.ar(effect  * amount);

	snd = snd * (1 - dryWet);
	effect = effect * dryWet;
	snd = snd + effect;

	snd = snd * amp;

	snd = LeakDC.ar(snd);

	Out.ar(out, snd);
}).add;

idDict
)