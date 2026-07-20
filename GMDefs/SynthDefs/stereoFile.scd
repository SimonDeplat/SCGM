(
var idDict = (
	name: "Stereo File",
	symbol: \gmStereoFile,
	category: \file,
	type: \filePlayer,
	emission: \discrete,
	tunable: false,
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
			symbol: \rate,
			default: 1,
			min: 0.25,
			max: 4,
			scale: \exp,
			text: "rate",
			modSteps: [0.01, 0.001]
		),

		(
			type: \buffer,
			symbol: \buffer,
			channels: 2
		),

		(
			type: \gate,
			symbol: \gate
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	]
);

SynthDef(\gmStereoFile, { |out = 0, buffer,
	gain = 1, amp = 1, rate = 1, gate = 1|

	var snd = PlayBuf.ar(
		2,
		buffer,
		rate,
		1.0,
		0,
		0,
		Done.freeSelf
	);

	var freeGate = EnvGen.kr(
		Env(
			[1, 0],
			[0.05],
			releaseNode: 0
		),
		gate,
		doneAction: Done.freeSelf
	);

	snd = snd * gain;
	snd = snd * freeGate;
	snd = snd * amp;
	Out.ar(out, snd);
}).add;

idDict
)