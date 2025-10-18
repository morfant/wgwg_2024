(
SynthDef(\LogicalSynthesis, {
    var sig, freqs, env;
    var amp = -6.dbamp;
    var pan;
    var out = 100;

    // Define the frequency components
    freqs = [100, 200, 300, 400, 500];

    // Rich Additive Synthesis
    sig = Mix.fill(freqs.size, { |i|
        SinOsc.ar(freqs[i]) * (1.0 / (i + 1))
    });

    // Apply an envelope
    env = EnvGen.kr(Env.perc(0.01, 0.2), doneAction: 2);

    // Apply amplitude and envelope
    sig = sig * amp * env;

    // Chaotic panning
    pan = LFNoise2.kr(1).range(-1, 1);
    sig = Pan2.ar(sig, pan);

    // Reverberation
    sig = FreeVerb.ar(sig, mix: 0.8);

    // Output to specified bus
    Out.ar(out, sig);
}).add;

Pdef(\LogicalSynthesis, {
    var dur = 0.2;
    Pbind(
        \instrument, \LogicalSynthesis,
        \dur, Pseq(Array.fill(10, dur), 18),
        \degree, Pseq([0, 2, 4, 5, 7, 9, 11, 12, 14, 16], 18),
        \scale, Scale.major,
        \octave, Pseq([4, 5, 6], 18)
    )
}).play;
)