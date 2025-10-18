(
SynthDef(\CoolBreezyDay, {
	arg out=0;
	var env, sig;
	env = EnvGen.kr(Env.perc(0.01, 1.99), doneAction: 2);
	sig = Mix([
		SinOsc.ar(440, 0, 0.1),
		Saw.ar(660, 0.1),
		Pulse.ar(880, 0.05, 0.1)
	]) * env;
	sig = sig * -6.dbamp;
	Out.ar(out, sig);
}).add;
)