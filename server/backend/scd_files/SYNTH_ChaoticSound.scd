(
SynthDef(\ChaoticSound, {
    var sig, env, freqs, amps, pan, reverb;

    freqs = Array.fill(10, { Rand(200, 2000) });
    amps = Array.fill(10, { Rand(0.1, 0.3) });

    sig = Mix(SinOsc.ar(freqs, 0, amps));
    sig = sig * 0.5;  // Scale down the amplitude to be around -6dB

    env = EnvGen.kr(Env.perc(0.01, 0.5), doneAction: 2);
    pan = Pan2.ar(sig, 0);  // Stable panning

    reverb = FreeVerb.ar(pan, mix: 0.5);  // Reverb of sound 50/100

    Out.ar(100, reverb * env);
}).add;

Pdef(\ChaoticSound, Pbind(
    \instrument, \ChaoticSound,
    \dur, Pseq([0.5, 0.6], inf),
    \degree, Pseq((0..7), inf),
    \scale, Scale.minor,
    \octave, 4,
    \amp, 0.8,
    \pan, 0,
    \out, 100
)).play;
)