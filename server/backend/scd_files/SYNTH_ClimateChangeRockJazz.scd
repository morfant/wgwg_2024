(
SynthDef(\ClimateChangeRockJazz, {
    var env, amp, sound, pan, melody, freq, trig;

    // Envelope
    env = EnvGen.kr(Env.perc(0.01, 20), doneAction: 2);
    
    // Amplitude
    amp = env * 0.794; // -2dB

    // Sound texture
    sound = Mix([
        // Simulating a rock texture with noise and resonant filters
        RLPF.ar(WhiteNoise.ar(amp), XLine.kr(500, 2000, 20), 0.2),
        BPF.ar(WhiteNoise.ar(amp), XLine.kr(1000, 4000, 20), 0.1)
    ]);

    // Melody (Jazz-like)
    trig = Impulse.kr(5); // Trigger for demand UGens
    freq = Demand.kr(trig, 0, Dseq([60, 62, 65, 67, 70, 72, 75, 77].midicps, 8));
    melody = SinOsc.ar(freq, 0, 0.5);

    // Panning
    pan = Pan2.ar(melody + sound, 0);

    Out.ar(0, pan);
}).add;
)