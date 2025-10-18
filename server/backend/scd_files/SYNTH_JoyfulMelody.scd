(
SynthDef(\JoyfulMelody, {
    |out=0|
    var trig, reset, freqSeq, freqs, env, sig;

    // Trigger and reset signals
    trig = Impulse.kr(1/16);  // Trigger every 16th of a second
    reset = Impulse.kr(0.2);  // Reset every 5 seconds

    // Frequency sequence with Demand UGen
    freqSeq = Dseq([440, 660, 880, 660, 440, 550, 770, 550], inf);
    freqs = Demand.kr(trig, reset, freqSeq);

    // Envelope for smooth transitions
    env = EnvGen.kr(Env.perc(0.01, 0.2), doneAction:2);

    // Signal generation with mid-low and high emphasis
    sig = SinOsc.ar(freqs) * 0.3;
    sig = sig + (SinOsc.ar(freqs * 2) * 0.15);  // Higher harmonic

    // Applying envelope
    sig = sig * env;

    // Pan the signal stably
    sig = Pan2.ar(sig, 0);

    // Output the signal
    Out.ar(out, sig);
}).add;
)