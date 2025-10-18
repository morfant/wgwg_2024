(
SynthDef(\WarmLoveSynth, {
    |out=100, amp=0.5, pan=0, freq=440|
    var sig, env, reverb;
    
    // Using Rich Additive synthesis
    sig = Mix.fill(10, { SinOsc.ar(freq * (1..10), 0, 1/10) });
    
    // Envelope for amplitude
    env = EnvGen.kr(Env.perc(0.01, 2), doneAction: 2);
    
    // Apply reverb
    reverb = FreeVerb.ar(sig, mix: 0.8, room: 0.8, damp: 0.5);
    
    // Apply panning and amplitude
    sig = Pan2.ar(reverb, pan, amp * env);
    
    // Output
    Out.ar(out, sig);
}).add;

Pdef(\WarmLoveSynth, 
    Pbind(
        \instrument, \WarmLoveSynth,
        \dur, Pseq([0.25, 0.5, 0.75, 1], 10),
        \freq, Pseq([440, 494, 523, 587, 659, 698, 784, 880, 988, 1047], 10).stutter(2),
        \pan, 0,
        \amp, 0.5,
        \out, 100
    )
).play;
)