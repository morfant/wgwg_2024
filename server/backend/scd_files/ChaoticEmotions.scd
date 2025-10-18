(
SynthDef(\ChaoticEmotions, {
    |out=0|
    var sig, del, freq, env;
    
    // Envelope for short and sharp bursts
    env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2);
    
    // Frequency modulated signal
    freq = LFNoise1.kr(10).range(100, 200); // Modulating frequency in the mid-low range
    sig = SinOsc.ar(freq) * env;
    
    // Adding harmonics with a slight detuning
    sig = sig + (SinOsc.ar(freq * 1.01) * env * 0.5);
    sig = sig + (SinOsc.ar(freq * 0.99) * env * 0.5);
    
    // Delay for chaotic spatial effect
    del = CombL.ar(sig, 0.1, LFNoise1.kr(5).range(0.01, 0.1), 0.2);
    
    // Panning the signal chaotically
    sig = Pan2.ar(del, LFNoise1.kr(1).range(-1, 1));

    // Output the signal
    Out.ar(out, sig * 0.5); // Adjusting overall volume to approx -6dB
}).add;
)