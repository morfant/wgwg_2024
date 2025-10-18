(
SynthDef(\EmotionalSynth, {
    |out=100, amp=0.5, pan=0|
    var sig, freqs, env;
    
    // Rich Additive synthesis
    freqs = [220, 440, 880, 1760];
    sig = Mix(SinOsc.ar(freqs) * 0.25);
    
    // Envelope
    env = EnvGen.kr(Env.perc(0.01, 2.99), doneAction: 2);
    
    // Apply envelope and amplitude
    sig = sig * env * amp;
    
    // Apply reverb
    sig = FreeVerb.ar(sig, mix: 0.5);
    
    // Pan the signal
    sig = Pan2.ar(sig, pan);
    
    // Output the signal
    Out.ar(out, sig);
}).add;

Pdef(\EmotionalSynth, Pbind(
    \instrument, \EmotionalSynth,
    \dur, 2.5,
    \degree, Pseq([
        [0, 2, 4, 5, 7].choose, // Melody line 1
        [0, 3, 5, 7, 10].choose // Melody line 2
    ], 19), // Repeat pattern less than 20 times
    \amp, 0.5,
    \pan, 0
)).play;
)