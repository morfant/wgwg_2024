(
SynthDef(\CapitalismPros, {
    var env, freq, trig, reset, demandUGens, sig, pan, amp, osc1, osc2, osc3, osc4, osc5;

    // Envelope
    env = EnvGen.kr(Env.new([0, 1, 0], [0.2, 19.6], [\sin, \lin]), doneAction: 2);

    // Amplitude
    amp = EnvGen.kr(Env([0, 0.8, 0], [0.01, 19.99], \sin), doneAction: 2) * -6.dbamp;

    // Frequency Demand UGens for high complexity melody
    freq = Demand.kr(Impulse.kr(6), 0, Dseq([Dshuf([200, 300, 400, 500, 600, 700, 800, 900, 1000], inf)], inf));

    // Oscillators for Additive synthesis
    osc1 = SinOsc.ar(freq * 1, 0, amp * 0.2);
    osc2 = SinOsc.ar(freq * 1.5, 0, amp * 0.2);
    osc3 = SinOsc.ar(freq * 2, 0, amp * 0.2);
    osc4 = SinOsc.ar(freq * 2.5, 0, amp * 0.2);
    osc5 = SinOsc.ar(freq * 3, 0, amp * 0.2);

    // Summing oscillators
    sig = (osc1 + osc2 + osc3 + osc4 + osc5) * env;

    // Panning
    pan = Pan2.ar(sig, 0);

    Out.ar(0, pan);
}).add;
)