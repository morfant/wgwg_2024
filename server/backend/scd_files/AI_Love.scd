(
SynthDef(\AI_Love, {
    arg out=0;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.01, 0.3), doneAction: 2);

    sig = Mix([
        SinOsc.ar(200, 0, 0.5),
        Saw.ar(LFNoise1.kr(0.5).range(100, 400), 0.5),
        Pulse.ar(LFNoise1.kr(0.2).range(50, 300), 0.3, 0.5)
    ]);

    sig = sig * env;
    sig = sig * EnvGen.kr(Env.perc(0.01, 5.0, 1, -4), doneAction: 2);  // Envelope for duration and amplitude
    sig = sig * 0.5; // Adjust overall volume to -6dB

    Out.ar(out, sig);
}).add;
)