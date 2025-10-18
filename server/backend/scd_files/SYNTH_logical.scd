(
SynthDef(\logical, {
    |out=100, amp=0.5, pan=0|
    var sig, env;
    
    // Main Synthesis method: Rich Additive
    sig = Mix.fill(10, { SinOsc.ar(rrand(50, 300)) });
    
    // Envelope
    env = EnvGen.kr(Env.perc(0.01, 0.2), doneAction: 2);
    
    // Apply amplitude and chaotic panning
    sig = sig * env * amp;
    sig = Pan2.ar(sig, LFNoise2.kr(1).range(-1, 1));
    
    // Reverberation
    sig = FreeVerb.ar(sig, mix: 0.8);
    
    // Output
    Out.ar(out, sig);
}).add;

Pdef(\logical, Pbind(
    \instrument, \logical,
    \dur, Pseq([0.2, 0.15, 0.1].choose, 10).stutter(3),
    \degree, Pseq((0..7).choose, 10).stutter(3),
    \amp, 0.5,
    \scale, Scale.major,
    \out, 100
)).play;
)