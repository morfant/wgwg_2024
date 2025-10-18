
s.waitForBoot {
(
SynthDef(\passion, {
    |freq = 440, amp = 0.5|
    var sig, env, dist;

    // Sawtooth wave
    sig = Saw.ar(freq, amp);

    // Distortion
    dist = sig.tanh * 2;

    // Reverb
    sig = FreeVerb.ar(dist, mix: 0.3);

    // Envelope
	// env = EnvGen.kr(Env.perc(0.01, 0.3), doneAction: 2);

	Out.ar(0, sig * LFPulse.ar([3, 2])!2 * 0.2);
}).play;
)
};
