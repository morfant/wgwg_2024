(
SynthDef(\ColdPersonWayOfLoveClimateChange, {
    var sig, env, reverb;
    var freqs = [200, 300, 400, 600];
    var amps = [0.3, 0.2, 0.15, 0.1];
    var pan = 0;
    
    // Rich Additive Synthesis
    sig = Mix(SinOsc.ar(freqs, 0, amps));
    
    // Envelope
    env = EnvGen.kr(Env.perc(0.01, 1.0), doneAction: 2);
    
    // Apply envelope
    sig = sig * env;
    
    // Final amplitude setting
    sig = sig * 0.5; // Adjust to achieve around -6dB
    
    // Reverberation
    reverb = FreeVerb.ar(sig, mix: 0.8, room: 0.8, damp: 0.5);
    
    // Output
    Out.ar(100, Pan2.ar(reverb, pan));
}).add;

Pdef(\ColdPersonWayOfLoveClimateChange, 
    Pbind(
        \instrument, \ColdPersonWayOfLoveClimateChange,
        \dur, Pseq([1, 0.5, 0.75, 1.5], 10),  // Pattern complexity low with repeat less than 20
        \freq, Pseq([200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300], 3),  // Serialism scale
        \amp, 0.5, // Final amplitude
        \pan, 0 // Stable panning
    ).play
);
)