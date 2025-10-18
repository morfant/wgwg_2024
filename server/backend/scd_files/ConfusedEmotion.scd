(
SynthDef(\ConfusedEmotion, {
    arg out=0;
    var sound, env, freq, pan;
    freq = [110, 220, 330, 440, 550, 660, 770, 880].choose;
    env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2);
    sound = SinOsc.ar(freq) * env * 0.5;
    pan = LFSaw.kr(1, 0, 1).range(-1, 1);
    Out.ar(out, Pan2.ar(sound, pan));
}).add;
)