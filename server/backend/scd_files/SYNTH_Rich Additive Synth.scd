(
SynthDef(\richAdditiveSynth, {
    |out=100, amp=0.5, pan=0, freq=440, reverbMix=0.8|
    var sig, env, rev;
    
    // Creating the additive synthesis signal
    sig = Mix.fill(10, { |i|
        var partial = SinOsc.ar(freq * (i + 1), 0, amp * (1.0 / (i + 1)));
        partial
    });
    
    // Applying chaotic panning
    sig = Pan2.ar(sig, LFNoise2.kr(1).range(-1, 1));
    
    // Enveloping
    env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2);
    sig = sig * env;
    
    // Adding reverb
    rev = FreeVerb.ar(sig, mix: reverbMix, room: 0.9, damp: 0.5);
    
    Out.ar(out, rev);
}).add;

Pdef(\richAdditiveSynth, Pbind(
    \instrument, \richAdditiveSynth,
    \dur, Pseq([0.2, 0.15, 0.1], inf),
    \freq, Pseq([60, 62, 64, 65, 67, 69, 71, 72, 74, 76].midicps, inf),
    \amp, Pseq([0.5, 0.6, 0.4, 0.7, 0.3, 0.8, 0.2, 0.9, 0.1, 1.0], inf),
    \reverbMix, 0.8,
    \out, 100
)).play;
)