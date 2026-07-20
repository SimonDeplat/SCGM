(
var idDict = (
	name: "Instr. Input",
	symbol: \gmInstrInput,
	category: \input,
	type: \input,
	emission: \continuous,
	tunable: false,
	dependencies: nil,

	params: [

		(
			type: \soundIn,
			symbol: \soundIn,
			numChannels: 1,
			text: "in",
		),

		(
			type: \continuous,
			symbol: \gain,
			default: 1,
			min: 1 / 3,
			max: 3,
			scale: \lin,
			text: "gain",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \lowCut,
			default: 20,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "low cut",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \highCut,
			default: 14000,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "high cut",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \amp,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			polarity: \uni,
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

SynthDef(\gmInstrInput, { |out = 0, soundIn,
	lowCut = 20, highCut = 14000,
	gain = 1, amp = 1|

	var snd = SoundIn.ar(soundIn, gain);

	// LOW & HIGH CUTS
	2.do({ snd = HPF.ar(snd, lowCut); });
	2.do({ snd = LPF.ar(snd, highCut); });

	snd = snd * amp;
	snd = snd.dup;

	Out.ar(out, snd);

}).add;

idDict
)