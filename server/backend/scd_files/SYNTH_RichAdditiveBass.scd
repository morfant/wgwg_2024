(
SynthDef(\RichAdditiveBass, {
    var sig, freqs, amps, env;
    freqs = Array.fill(20, { |i| (i+1) * SinOsc.kr(0.1).range(50, 1000) });
    amps = Array.fill(20, { |i| 1.0 / (i+1) });
    sig = Mix(SinOsc.ar(freqs, 0, amps));
    sig = sig * 0.5; // Amplitude adjustment
    env = EnvGen.kr(Env.perc(0.01, 0.99), doneAction: 2);
    sig = sig * env;
    sig = Pan2.ar(sig, 0); // Stable panning
    sig = sig * 0.5; // Final amplitude to approximately -6dB
    sig = FreeVerb.ar(sig, 0.5, 0.5, 0.5); // Reverberation
    Out.ar(0, sig);
}).add;

Pdef(\RichAdditiveBass, 
    Pbind(
        \instrument, \RichAdditiveBass,
        \dur, Pseq([3.0, 2.5, 2.7, 2.8, 2.6, 3.0, 2.5, 2.7, 2.8, 2.6], 5), // 50 notes in total
        \freq, Pseq([60, 62, 65, 67, 69, 72, 74, 77, 79, 81], 5).midicps, // Minor scale concept
        \amp, 0.5
    )
).play;
)