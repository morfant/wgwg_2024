(
SynthDef(\ClimateCrisisNeoliberalJoy, {
    |out=0, freq=440, amp=0.5, pan=0|
    var signal, env;
    var harmonics = Mix.fill(10, { |i| SinOsc.ar(freq * (i + 1), 0, amp / (i + 1)) });
    env = EnvGen.kr(Env.perc(0.01, 0.2), doneAction: 2);
    signal = harmonics * env;
    Out.ar(out, Pan2.ar(signal, pan, amp));
}).add;

Pdef(\ClimateCrisisNeoliberalJoy, Pbind(
    \instrument, \ClimateCrisisNeoliberalJoy,
    \dur, Pseq([0.2, 0.3, 0.4, 0.5], inf),
    \freq, Pseq([60, 62, 63, 65, 67, 68, 70, 72, 73, 75,
                 77, 78, 80, 82, 83, 85, 87, 88, 90, 92,
                 93, 95, 97, 98, 100, 102, 103, 105, 107, 108,
                 110, 112, 113, 115, 117, 118, 120, 122, 123, 125,
                 127, 128, 130, 132, 133, 135, 137, 138, 140, 142], inf),
    \amp, 0.25,
    \pan, Pwhite(-0.5, 0.5, inf)
)).play;
)