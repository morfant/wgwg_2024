(
SynthDef(\AIlove, {
    arg out=0;
    var env, sig;
    env = EnvGen.kr(Env.perc(0.01, 1), doneAction:2);
    sig = Mix([
        SinOsc.ar(XLine.kr(800, 400, 4), 0, 0.5),
        Saw.ar(XLine.kr(400, 200, 4), 0.5),
        Pulse.ar(XLine.kr(200, 100, 4), 0.5, 0.5),
        WhiteNoise.ar(0.3)
    ]);
    sig = sig * env;
    sig = sig.distort * 0.5;
    sig = sig * Line.kr(1, 0, 5);  // fade out
    Out.ar(out, sig);
}).add;
)