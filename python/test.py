from pythonosc import udp_client

client = udp_client.SimpleUDPClient("127.0.0.1", 57110)

# 등록된 \sine_wave SynthDef 실행
client.send_message("/s_new", ["sine_wave", 1300, 0, 1, "freq", 100, "amp", 0.5])
