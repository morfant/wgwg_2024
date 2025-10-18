(
SynthDef(\MazeSynth, {
    arg out=100, amp=0.5, pan=0;
    var sig, env;
    var freqs = [220, 440, 660, 880, 1100];

    // Main Synthesis using waveshaping
    sig = Mix.fill(5, { |i|
        var osc = SinOsc.ar(freqs[i]);
        var shape = (i + 1) * 0.1;
        Shaper.ar(Buffer.read(s, "/Users/giy/WGWG/server/backend/static/sample.wav").bufnum, osc, shape)
    });

    // Amplitude Envelope
    env = EnvGen.kr(Env.perc(0.01, 1.0), doneAction: 2);

    // Apply envelope, panning, and final amplitude
    sig = Pan2.ar(sig * env, pan, amp.dbamp);

    // Reverberation
    sig = FreeVerb.ar(sig, mix: 0.8);

    // Output
    Out.ar(out, sig);
}).add;

Pdef(\MazeSynth, Pbind(
    \instrument, \MazeSynth,
    \dur, Pseq([1.2, 1.1], inf).trace,
    \amp, 0.5,
    \pan, 0,
    \degree, Pseq((0..4), 5),
    \scale, Scale.chromatic,
    \octave, 5,
    \out, 100
)).play;
)