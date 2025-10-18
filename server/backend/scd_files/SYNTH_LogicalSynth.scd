(
SynthDef(\LogicalSynth, {
    |out=100, amp=0.5, pan=0|
    var sig, env, freqs, osc;
    
    // Main synthesis method: Rich Additive
    freqs = [100, 200, 300, 400, 500];
    osc = Mix(SinOsc.ar(freqs, 0, [1, 0.8, 0.6, 0.4, 0.2]));
    
    // Envelope
    env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2);
    sig = osc * env;
    
    // Panning
    sig = Pan2.ar(sig, LFNoise1.kr(1).range(-1, 1));
    
    // Reverberation
    sig = FreeVerb.ar(sig, mix: 0.8);
    
    // Final amplitude
    sig = sig * amp;
    
    Out.ar(out, sig);
}).add;

Pdef(\LogicalSynth, Pbind(
    \instrument, \LogicalSynth,
    \dur, Pseq([0.2, 0.1, 0.2, 0.1, 0.2, 0.1, 0.2, 0.1, 0.2, 0.1], 10),
    \degree, Pseq([0, 2, 4, 5, 7, 9, 11, 12, 14, 16], 10),
    \scale, Scale.major,
    \amp, 0.5,
    \pan, Pwhite(-1, 1)
)).play;
)