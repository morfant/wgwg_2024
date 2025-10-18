// 서버 실행
s.boot;

// 모스 부호 사운드 Synth 정의
(
SynthDef(\morse, { |freq = 660, dur = 0.1, amp = 0.2|
	var sig = SinOsc.ar(freq) * EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
	Out.ar(0, Pan2.ar(sig * amp));
}).add;
)


// OSC 수신 설정
(
OSCdef(\morseCode, { |msg|
	var str, list;
    var shortDur = 0.1;  // 짧은 소리 지속 시간
    var longDur = 0.3;   // 긴 소리 지속 시간
    var pauseDur = 0.5;  // 공백 대기 시간

	// msg[1].postln;  // 수신된 메시지 출력
	str = msg[1].asString;
	list = Array.newClear(str.size);

	str.do{|char , i|
		if (char.asString == "0", {list.put(i, shortDur)});
		if (char.asString == "1", {list.put(i, longDur)});
		if (char.asString == "2", {list.put(i, pauseDur)});
		// list.put(i, char);
	};
	list.postln;

	// ~playMorseCode.value(list);  // 두 번째 인자를 모스 부호 재생 함수에 전달
    ~morse_base_1 = Pdef(\morsePlayer_1,
		Pbind(
			\instrument, \morse,
			\freq, 600,
			\tempo, 1.0,
			\dur, Pseq(list, inf) * Pfunc { |ev| ev[\tempo] },

    ));

	~morse_chain_1.stop;
	~morse_chain_1 =
	(Pbind(\tempo, 1.0) <> ~morse_base_1).play;

}, '/morse_code_1', recvPort: 57120);
)



// 테스트용 OSC 메시지 전송 (클라이언트에서 전송 시 동일한 포맷)
(
m = NetAddr("127.0.0.1", NetAddr.langPort); // loopback

m.sendMsg('/morse', [0, 1, 2, 1, 2, 0]);
)





