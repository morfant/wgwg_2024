(
SynthDef(\WarmWindSound, {
    |out|
    var freq1, freq2, ampEnv, sig1, sig2, combined, pan;

    // Frequency sequences with a high complexity
    freq1 = Demand.kr(Impulse.kr(5), 0, Dseq([60, 62, 63, 65, 67, 68, 70, 72, 74, 75].scramble, 5)).midicps;
    freq2 = Demand.kr(Impulse.kr(5), 0, Dseq([48, 50, 51, 53, 55, 57, 58, 60, 62, 63].scramble, 5)).midicps;

    // Amplitude envelope
    ampEnv = EnvGen.kr(Env.new([0, 1, 0], [0.01, 0.99], \sin, 1), doneAction: 2);

    // Rich additive synthesis
    sig1 = SinOsc.ar(freq1, 0, 0.3) + SinOsc.ar(freq1 * 2, 0, 0.2) + SinOsc.ar(freq1 * 3, 0, 0.1);
    sig2 = SinOsc.ar(freq2, 0, 0.3) + SinOsc.ar(freq2 * 2, 0, 0.2) + SinOsc.ar(freq2 * 3, 0, 0.1);

    // Combine signals
    combined = (sig1 + sig2) * ampEnv;

    // Panning
    pan = Pan2.ar(combined, 0);

    // Output
    Out.ar(out, pan);
}).add;
)