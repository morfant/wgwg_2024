(
SynthDef(\LoveRough, {
    |out=0|
    var sig, env;
    // 소리 생성
    sig = Mix([LFNoise1.kr([6, 4]), BrownNoise.ar, Saw.ar([200, 300])]);
    // 거친 소리 가공
    sig = sig * EnvGen.kr(Env.perc(0.01, 0.15), doneAction: 2);
    sig = sig * LFNoise2.kr(8).range(0.5, 1);
    sig = sig + Resonz.ar(WhiteNoise.ar, LFNoise1.kr(4).range(400, 800), 0.1);
    sig = sig.tanh;
    // 소리 크기 조절 -6dB
    sig = sig * 0.501;
    // 소리 길이 설정
    env = EnvGen.kr(Env.linen(0.01, 5 + 3 * LFNoise1.kr(2).range(0, 1), 0.1), doneAction: 2);
    sig = sig * env;
    Out.ar(out, sig);
}).add;
)