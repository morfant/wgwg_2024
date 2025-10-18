// SuperCollider 서버에 연결
s.waitForBoot {
    // SynthDef 정의 및 서버에 등록
    SynthDef(\sine_wave, {
        |freq = 100, amp = 0.5|
        Out.ar(0, SinOsc.ar(freq, 0, amp));
    }).add;
};
