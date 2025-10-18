(
SynthDef(\ChildLove, {
    |out=0|
    var sig, env, pan, freq, amp;
    
    // Envelope for amplitude control
    env = EnvGen.kr(Env.perc(0.1, 1.5, 1.0, -4), doneAction: 2);
    
    // Frequency for mid-low range emphasis
    freq = LFNoise1.kr(0.5).exprange(150, 400);
    
    // Amplitude modulation for -6dB
    amp = env * 0.5;
    
    // Sound source: Sine wave with slight detuning for a richer texture
    sig = Mix(SinOsc.ar([freq, freq * 1.01], 0, amp));
    
    // Panning: LFO for random panning effect
    pan = LFSaw.kr(0.1).range(-1, 1);
    
    // Apply pan
    sig = Pan2.ar(sig, pan);
    
    // Output the signal
    Out.ar(out, sig);
}).add;
)