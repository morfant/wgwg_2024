(
SynthDef(\ConfusedEmotions, {
    |out = 0|
    var freq, env, sig;

    freq = LFNoise2.kr([1.5, 1.2]).range(100, 300); // Random frequency modulation in mid-bass range
    env = EnvGen.kr(Env.perc(0.1, 5.9), doneAction: 2); // Envelope for the sound's duration

    sig = SinOsc.ar(freq) * env; // Sine wave oscillator with envelope
    sig = sig * 0.5; // Adjust volume to -6dB

    sig = Splay.ar(sig, spread: 1.0); // Spread the signal for a confusing stereo image

    Out.ar(out, sig);
}).add;
)