(
SynthDef(\ChildLoveTheme, {
	arg out=0;
	var sound, env;
	
	sound = SinOsc.ar(
		[
			100, 200
		],
		0,
		[
			LFNoise1.kr(0.1).range(0.5, 0.7), 
			LFNoise1.kr(0.1).range(0.5, 0.7)
		]
	);
	
	sound = BPF.ar(sound, [120, 180], 0.1);
	sound = LPF.ar(sound, 2500);
	sound = sound * EnvGen.kr(Env.perc(0.5, 5), doneAction: 2);
	
	sound = sound * 0.5;
	
	Out.ar(out, sound);
}).add;
)