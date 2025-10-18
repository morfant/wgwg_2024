(
SynthDef(\AngrySound, {
	arg out=0;
	var env, osc1, osc2, osc3, mix, ampEnv;
	
	ampEnv = EnvGen.kr(Env.perc(0.01, 0.5), doneAction: 2);

	osc1 = Saw.ar(80 + (LFNoise1.kr(2).range(0, 300)), 0.5);
	osc2 = Pulse.ar(100 + (LFNoise1.kr(3).range(0, 200)), 0.5, 0.3);
	osc3 = LFSaw.ar(60 + (LFNoise1.kr(1).range(0, 150)), 0.5);
	
	mix = Mix([osc1, osc2, osc3]) * ampEnv;
	
	env = EnvGen.kr(Env([0, 1, 0], [5, 3]), doneAction: 2);
	
	Out.ar(out, mix * env * -6.dbamp);
}).add;
)