
(
// 기본 모스 부호 사운드

SynthDef(\morse_1, { |freq = 140, dur = 0.2, amp = 0.1|
	var sig = Impulse.ar(0) * Line.ar(1, 0, 0.5, doneAction: 2);
	sig = Ringz.ar(sig, freq*2, 0.1);
    Out.ar(0, Pan2.ar(sig * amp, 0));
}).add;

SynthDef(\morse_2, { |freq = 770, dur = 0.15, amp = 0.1|
    var sig = LFPar.ar(freq/6, 0.5) * EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    Out.ar(0, Pan2.ar(sig * amp, 0.5));
}).add;

// legato 조절 가능
// SynthDef(\morse_3, { |freq = 660, rel = 0.1, amp = 0.1, dt = 0.009, gate = 1.0|
// 	var sig = Ringz.ar(BrownNoise.ar() * Linen.kr(gate, 0.001, 1.0, rel, 2), freq*4, dt);
// 	sig = HPF.ar(sig, 800);
// 	Out.ar(0, Pan2.ar(sig * amp));
// }).add;

SynthDef(\morse_3, { |freq = 660, dur = 0.1, amp = 0.1, dt = 0.009, gate = 1.0|
	var sig = Ringz.ar(BrownNoise.ar(0.4) * EnvGen.kr(Env.perc(0.01, dur), doneAction: 2), freq*4, dt);
	sig = HPF.ar(sig, 800);
    Out.ar(0, Pan2.ar(sig * amp, -0.5));
}).add;

SynthDef(\morse_4, { |freq = 660, dur = 0.1, amp = 0.7|
	var sig = LFSaw.ar(freq/6, mul: amp) * EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
	Out.ar(0, Pan2.ar(sig, 0.8));
}).add;

SynthDef(\morse_5, {|freq = 800, f_div = #[100.0, 300.0], amp = 2, gate = 1.0|
    var im, pc, sig;
	im = Impulse.ar(2);
	pc = PulseCount.ar(im);
	gate = pc < 1;
    sig = Decay2.ar(
		im * LFSaw.kr(0.3, 1, -0.3, 0.3),
        0.01,
        0.3
		) * Mix.ar(Pulse.ar([80 + (freq/f_div[0]), 81 + (freq/f_div[1])], 0.3))
	// ) * Mix.ar(Pulse.ar([80 + (300/f_div[0]), 81 + (500/f_div[1])], 0.3))
	// ) * Mix.ar(Pulse.ar([80 + (600/f_div[0]), 81 + (1000/f_div[1])], 0.3))
	// ) * Mix.ar(Pulse.ar([80 + (900/f_div[0]), 81 + (1500/f_div[1])], 0.3))
	// ) * Mix.ar(Pulse.ar([80 + (1200/f_div[0]), 81 + (2000/f_div[1])], 0.3))
// ) * Mix.ar(Pulse.ar([80 + (1500/f_div[0]), 81 + (2500/f_div[1])], 0.3))
	* Linen.kr(gate, doneAction: 2) * 5;
	Out.ar(0, Pan2.ar(sig * amp));
}).add;


// Button sounds - Not using
SynthDef(\sound_1,
	{
		arg lfreq = 1/5, freq = 500, dt = 0.07, amp = 0.5;
		var sig, lfo;
		sig = LPF.ar(WhiteNoise.ar(1), 600);
		sig = Ringz.ar(sig, freq, dt);

		lfo = LFPar.kr(lfreq, 1.0.rand).range(-0.1, 0.1);
		Out.ar(0, Pan2.ar(sig * lfo, 0, amp));
	}
).add;

SynthDef(\sound_2,
	{
		arg lfreq = 1/5, freq = 1500, dt = 0.04, amp = 0.5;
		var sig, lfo;
		sig = Ringz.ar(BrownNoise.ar(1), freq, dt);
		lfo = LFPar.kr(lfreq, 1.0.rand).range(-0.1, 0.1);
		Out.ar(0, Pan2.ar(sig * lfo, 0, amp));
	}
).add;

SynthDef(\sound_3,
	{
		arg lfreq = 121, freq = 900, dt = 0.07, amp = 0.5;
		var sig, lfo;
		sig = Ringz.ar(Blip.ar(100, 200), freq, dt);
		lfo = LFPar.kr(lfreq, 1.0.rand);
		Out.ar(0, Pan2.ar(sig * lfo, 0, amp));
	}
).add;

SynthDef(\sound_4,
	{
		arg lfreq = 1/5, freq = 3500, dt = 0.02, amp = 0.5;
		var sig, lfo;
		sig = DynKlank.ar(`[[800, 1071, 1353, 1723], nil, [1, 1, 1, 1]], PinkNoise.ar(0.07));
		lfo = LFPar.kr(lfreq, 1.0.rand).range(-0.1, 0.1);
		Out.ar(0, Pan2.ar(sig * lfo, 0, amp));
	}
).add;

SynthDef(\sound_5,
	{
		arg lfreq = 1/5, dt = 0.02, amp = 0.5;
		var sig, lfo;
		sig = DynKlank.ar(`[[800, 1071, 1353, 1723]*1.4, nil, [1, 1, 1, 1]], BrownNoise.ar(0.07));
		lfo = LFPar.kr(lfreq, 1.0.rand).range(-0.1, 0.1);
		Out.ar(0, Pan2.ar(sig * lfo, 0, amp));
	}
).add;



// Reverb
SynthDef(\FreeVerb2x2, { |out, mix = 0.25, room = 0.15, damp = 0.5, amp = 1.0|
    var signal;

    signal = In.ar(out, 2);

    ReplaceOut.ar(out,
        FreeVerb2.ar( // FreeVerb2 - true stereo UGen
            signal[0], // Left channel
            signal[1], // Right Channel
            mix, room, damp, amp
        )
    ); // same params as FreeVerb 1 chn version

}).add;

// Limiter
SynthDef(\Limiter, {|in = 0, ceil = 0.8, relTime = 0.01, amp = 0.8|
	var source, limitedSignal;

	limitedSignal = Limiter.ar(In.ar(in, 2), ceil, relTime);

	Out.ar(0, Pan2.ar(limitedSignal, 0, amp));
}).add;
)

