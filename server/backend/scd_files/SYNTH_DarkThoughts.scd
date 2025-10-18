(
SynthDef(\DarkThoughts, {
    var sig, freqs, env, amp, pan;
    freqs = [200, 300, 400, 500, 600, 700];
    sig = Mix.fill(freqs.size, { |i| SinOsc.ar(freqs[i], 0, 0.1) });
    env = EnvGen.kr(Env.perc(0.01, 0.2), doneAction: 2);
    amp = env * 0.5; // Final amplitude around -6dB
    pan = 0; // stable panning
    Out.ar(0, Pan2.ar(sig * amp, pan));
}).add;

Pdef(\DarkThoughts, Pbind(
    \instrument, \DarkThoughts,
    \dur, Pseq([0.2, 0.3, 0.4, 0.5], 5),
    \scale, Scale.minor,
    \degree, Pseq((0..7), 10),
    \octave, Pseq([4, 5], 10),
    \complexity, \high,
    \repeat, Pseq([10, 15, 5, 10], 5)
)).play;
)