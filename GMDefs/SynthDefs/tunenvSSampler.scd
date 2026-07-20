(
var idDict = (
	name: "Tunenv S Sampler",
	symbol: \gmTunenvSSampler,
	category: \file,
	type: \filePlayer,
	emission: \discrete,
	tunable: true,
	dependencies: nil,

	params: [
		(
			type: \continuous,
			symbol: \gain,
			default: 1,
			min: 0.1,
			max: 3,
			scale: \lin,
			text: "gain",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \amp,
			default: 1,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			modSteps: [0.01, 0.001],
			displayFunction: { |value|
				(value.ampdb.trunc(0.01).asString ++ " db")
			},
		),

		(
			type: \continuous,
			symbol: \tuning,
			default: 440,
			min: 220,
			max: 880,
			scale: \exp,
			text: "tuning",
			modSteps: [0.01, 0.001]
		),

		(
			type: \buffer,
			symbol: \buffer,
			channels: 2
		),

		(
			type: \env,
			symbol: \env,
			maxSize: 9,
			default: Env(
				[0, 1, 0],
				[0.001, 0.4],
				[0, 0]
			),
			min: 0,
			max: 1,
			text: "env",
			timeScale: 2.0,
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 1,
			values: [4, 2, 1, 0.5, 0.25],
			text: "freq mul.",
			texts: ["x4", "x2", "-", "/2", "/4"],
		),

		(
			type: \continuous,
			symbol: \spread,
			default: 1,
			min: 1,
			max: 2,
			scale: 8,
			text: "spread",
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: true,
			helpersRatio: 0.05,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 1,
			// Mod Steps
			modStep: 1.01,
			modStepOperator: \mul,
			modStep2: 1.001,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				value = value - 1;
				value = value * 100;
				if(value < 10) {
					value = value.trunc(0.01);
				} {
					value = value.asInteger;
				};
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

SynthDef(\gmTunenvSSampler, { |out = 0, buffer,
	gain = 1, amp = 1, freq = 440, tuning = 440,
	freqMul = 1, spread = 1|

	var env = Env.newClear(9);

	var envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	var rate = (freq / tuning) * freqMul;

	var snd = PlayBuf.ar(
		2,
		buffer,
		rate * [spread.reciprocal, spread],
		1.0,
		0,
		0,
		Done.freeSelf
	);

	snd = snd * gain;
	snd = snd * envGen;
	snd = snd * amp;

	Out.ar(out, snd);
}).add;

idDict
)