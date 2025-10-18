
(// Run first
// Sounds
"./sounds.scd".loadRelative;
)

(
/*
A: 100 Hz
B: 228 Hz
C: 356 Hz
D: 484 Hz
E: 612 Hz
F: 740 Hz
G: 868 Hz
H: 996 Hz
I: 1124 Hz
J: 1252 Hz
K: 1380 Hz
L: 1508 Hz
M: 1636 Hz
N: 1764 Hz
O: 1892 Hz
P: 2020 Hz
Q: 2148 Hz
R: 2276 Hz
S: 2404 Hz
T: 2532 Hz
U: 2660 Hz
V: 2788 Hz
W: 2916 Hz
X: 3044 Hz
Y: 3172 Hz
Z: 3300 Hz
*/

//Vars
~all_char_len = 0;
~synth_1 = nil;~synth_2 = nil;~synth_3 = nil;~synth_4 = nil;~synth_5 = nil;

~morse_harmonic = Array.newClear(7);
~morse_harmonic[0] = [500, 700, 900, 400, 600].scramble; // Not using

~morse_harmonic[1] = [740, 2276, 1124, 2532, 3300, 740, 2276]; // FRITZFR
~morse_harmonic[2] = [484, 1892, 1764, 1764, 100, 484]; // DONNAD
~morse_harmonic[3] = [228, 612, 1764, 228, 612, 1764]; // BENBEN
~morse_harmonic[4] = [484, 100, 1764, 484, 100, 1764]; // DANDAN
~morse_harmonic[5] = [2532, 1892, 1636, 2532, 1892, 1636]; // TOMTOM

~morse_harmonic[6] = [500, 700, 900, 400, 600, 100, 1500, 2100].scramble;


~m_tmps = Array.fill(6, {1.0});
~m_amps = Array.fill(6, {1.0});

~morse_base = Array.newClear(100);
~morse_chain = Array.newClear(100);

~t_clocks = Array.fill(10, {TempoClock.new()});



// Functions
~setAmp = Pbind(\amp, Pfunc { |ev| ev[\amp] * ev[\m_amp] });

~print_arr = {|arr|
	arr.do{|item, index|
		("item: " + item + " index: " + index).postln;
	}
};


// MorseCodes Receiver
OSCdef(\morseCode, { |msg|
	var idx, str, list;
	var shortDur = 0.1;  // 짧은 소리 지속 시간
	var longDur = 0.3;   // 긴 소리 지속 시간
	var pauseDur = 0.6;  // 공백 대기 시간
	var longpauseDur = 1.2;  // 문장 사이 공백 시간
	var amps = [0.1, 0.1, 0.05, 0.08, 0.06];


	idx = msg[2].asInteger;
	("========= MoseCode "++idx++" =========").postln;
	("msg: "++msg).postln;  // 수신된 메시지 출력
	str = msg[1].asString;
	~all_char_len = ~all_char_len + str.size;
	("~all_char_len: "++~all_char_len).postln;
	("str: " + str).postln;
	("idx: " + idx).postln;
	list = Array.newClear(str.size);

	str.do{|char , i|
		if (char.asString == "0", {list.put(i, shortDur)});
		if (char.asString == "1", {list.put(i, longDur)});
		if (char.asString == "2", {list.put(i, pauseDur)});
		if (char.asString == "3", {list.put(i, longpauseDur)});
	};
	("list: "++list).postln;

	~morse_base[idx] = Pdef("morsePlayer_"++idx,
		Pbind(
			\instrument, "morse_"++idx,
			// \midinote, 68,
			\freq, Pseq(~morse_harmonic[idx], inf),
			\detune, 0.0,
			\tempo, ~m_tmps[idx],
			\m_amp, ~m_amps[idx],
			\amp, amps[idx-1],
			\dur, Pseq(list, inf),

	));

	~morse_chain[idx].stop;
	~morse_chain[idx] =
	(~setAmp <> ~morse_base[idx]).play(~t_clocks[idx]);

}, '/morse_code', recvPort: 57120);





// Buttons
OSCdef(\buttons, { |msg, time, addr, port|
	var group, index, value;
	#group, index, value = msg[1..];
	("====Button_"++group++"_"++index++"====").postln;
	// msg[1].postln;
	// msg[1].class.postln;
	switch(group,
		1, {
			SynthDef(\morse_1, { |freq = 140, dur = 0.2, amp = 0.1|
				var sig = Impulse.ar(0) *
				Line.ar(1, 0, 0.5, doneAction: 2);
				sig = Ringz.ar(sig, freq*index, 0.1);
				Out.ar(0, Pan2.ar(sig * amp, 0));
			}).add;
		},
		2, {
			SynthDef(\morse_2, { |freq = 770, dur = 0.15, amp = 0.1|
				var sig = LFPar.ar(freq/index, 0.5) *
				EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
				Out.ar(0, Pan2.ar(sig * amp, 0.5));
			}).add;
		},
		3, {
			SynthDef(\morse_3, { |freq = 660, dur = 0.1, amp = 0.1, dt = 0.009|
				var sig = Ringz.ar(
					BrownNoise.ar(0.4) *
					EnvGen.kr(Env.perc(0.01, dur), doneAction: 2), freq*index, dt);
				sig = HPF.ar(sig, 800);
				Out.ar(0, Pan2.ar(sig * amp, -0.5));
			}).add;

		},
		4, {
			SynthDef(\morse_4, { |freq = 660, dur = 0.1, amp = 0.01|
				var sig = LFSaw.ar(freq/(index*1.5), mul: 0.7) *
				EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
				Out.ar(0, Pan2.ar(sig, 0.8, amp));
			}).add;

		},
		5, {
			SynthDef(\morse_5, {|freq = 800, f_div = #[100.0, 300.0], amp = 2, gate = 1.0|
				var im, pc, sig;
				im = Impulse.ar((index/2) + 1);
				pc = PulseCount.ar(im);
				gate = pc < 1;
				sig = Decay2.ar(
					im * LFSaw.kr(0.3, 1, -0.3, 0.3),
					0.01,
					0.4
			) * Mix.ar(Pulse.ar([80 + ((index*300.0)/f_div[0]), 81 + ((index*500.0)/f_div[1])], 0.3))
				* Linen.kr(gate, doneAction: 2) * 5;
				Out.ar(0, Pan2.ar(sig * amp));
			}).add;

		},
		{}
	);


}, '/play_synth', recvPort: 57120);


// Sliders
OSCdef(\sliders, { |msg, time, addr, port|
	var group, index, value, val;
	#group, index, value = msg[1..];
	("====Slider_"++group++"_"++index++"====").postln;

	val = value.asInteger;
	// val.class.postln;
	// val.postln;

	if (group != 0, {
		if (index == 1, { // Tempo
			val = val.linlin(5, 100, 0.1, 2.0);
			~m_tmps[group] = val;
			("~m_tmps["++group++"]: "++~m_tmps[group]).postln;
			~morse_chain[group].stop;
			~morse_chain[group] =
			(~setAmp <> Pbind(\tempo, ~m_tmps[group]) <>
				~morse_base[group]).play(~t_clocks[group]);
		});
		if (index == 2, { // Volume
			val = val.linlin(5, 100, 0.0, 2.0);
			~m_amps[group] = val;
			("~m_amps["++group++"]: "++~m_amps[group]).postln;
			~morse_chain[group].stop;
			~morse_chain[group] =
			(~setAmp <>
				Pbind(\m_amp, ~m_amps[group]) <>
				~morse_base[group]).play(~t_clocks[group]);
		});
	});

	if (group == 0, { // Reverb
		val = val.linlin(5, 100, 0.1, 1.0);
		~rev.set(\mix, val, \room, val);
	});



}, '/set_slider', recvPort: 57120);





// Reverb
~rev = Synth(\FreeVerb2x2, [
	\outbus, 0,
	\mix, 0.25,
	\room, 0.25,
	\damp, 0.5,
], addAction:\addToTail);


// Limiter
~lim = Synth(\Limiter, [
	\in, 0,
	\ceil, 0.8,
	\relTime, 0.01,
	\amp, 0.8
], target: ~rev, addAction: \addBefore);



)



s.dumpOSC(1); // 0: off, 1: on-parsed, 2: on-hex, 3: on-both
s.dumpOSC(0); // 0: off, 1: on-parsed, 2: on-hex, 3: on-both




// _가 포함된 이름을 제외한 등록된 Synth 이름을 가져오는 예제
(
SynthDescLib.global.synthDescs
.select { |desc| desc.name.contains("_").not }  // _가 포함되지 않은 항목만 선택
.collect { |desc| desc.name }
.do { |synthName| synthName.postln; };
)



