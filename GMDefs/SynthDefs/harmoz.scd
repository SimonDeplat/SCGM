(
var idDict = (
	name: "Harmoz",
	symbol: \gmHarmoz,
	category: \synth,
	type: \synth,
	emission: \discrete,
	tunable: true,
	dependencies: nil,

	params: [
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
			type: \continuous,
			symbol: \amp,
			default: 0.6,
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
			type: \discrete,
			symbol: \freqMul,
			default: 1,
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

SynthDef(\gmHarmoz, { |out = 0, freq = 440,
	freqMul = 1, amp = 0.8, spread = 1.0|

	var env, envGen;
	var amps;
	var snd;
	var synthFreq;

	env = Env.newClear(9);
	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	amps = NamedControl.kr(
		\amps,
		[1, 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8, 1/9]
	);

	snd = Silent.ar;

	synthFreq = freq * freqMul;
	synthFreq = synthFreq * [
		spread,
		spread.reciprocal
	];

	9.do({ |index|
		snd = snd +
		SinOsc.ar(
			synthFreq * (index + 1),
			(index % 2) * pi,
			amps[index]
		);
	});

	snd = snd * amp;
	snd = snd * envGen;

	// Reduce volume
	// to normalize perception
	snd = snd / 2;

	Out.ar(out, snd);
}).add;

idDict
)