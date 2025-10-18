SynthDef("WarmBreezeLandscape", {
    |out=0|
    var env, freqs, notes1, notes2, trig, pan, sig;

    env = Env.new([0, 1, 0], [0.01, 0.99], 'linear').kr(gate: 1, doneAction: 2);

    notes1 = Demand.ar(
        Dust.ar(0.5),
        0,
        Dseq(Dshuf((60..72).midicps, 50), inf)
    );

    notes2 = Demand.ar(
        Dust.ar(0.5),
        0,
        Dseq(Dshuf((48..60).midicps, 50), inf)
    );

    freqs = Mix([notes1, notes2]);

    sig = SinOsc.ar(freqs) * env;
    pan = LFNoise2.kr(0.5).range(-0.2, 0.2);
    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig * 0.25)
}).add;