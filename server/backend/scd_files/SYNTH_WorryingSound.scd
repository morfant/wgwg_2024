(
SynthDef(\WorryingSound, {
	arg out=0;
	var freqs, env, sig, panPos, trig, dur, amp;
	
	dur = Dseq([0.1, 0.2, 0.15, 0.25], inf);
	trig = Impulse.ar(Demand.kr(trig: Impulse.kr(0), reset: 0, demand: dur));

	freqs = Dshuf([200, 250, 300, 350, 400, 450, 500], inf);
	amp = Dshuf([0.5, 0.6, 0.7, 0.8], inf);

	env = EnvGen.ar(Env.perc(0.01, 0.1, curve: -4), trig);

	sig = SinOsc.ar(Demand.kr(trig, 0, freqs), 0, env * Demand.kr(trig, 0, amp));

	panPos = Dshuf([-1, -0.5, 0, 0.5, 1], inf);
	sig = Pan2.ar(sig, Demand.kr(trig, 0, panPos), 1);

	Out.ar(out, sig * 0.5);
}).add;
)