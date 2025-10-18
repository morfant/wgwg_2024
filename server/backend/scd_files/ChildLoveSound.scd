(
SynthDef(\ChildLoveSound, {
    arg out=0;
    var env, osc, rev, sig;
    
    // Amplitude envelope
    env = EnvGen.kr(Env.perc(0.1, 4.9, 1, -4), doneAction: 2);
    
    // Oscillator with a Bach-like harmony
    osc = Mix([
        SinOsc.ar(440, 0, 0.5),  // A4
        SinOsc.ar(523.25, 0, 0.3),  // C5
        SinOsc.ar(659.25, 0, 0.2),  // E5
        SinOsc.ar(783.99, 0, 0.1)  // G5
    ]) * env;
    
    // Simple reverb for a more religious feel
    rev = FreeVerb.ar(osc, mix: 0.5, room: 0.8, damp: 0.2);
    
    // Final output
    sig = rev * 0.5; // Adjust overall gain to -6dB
    Out.ar(out, sig);
}).add;
)