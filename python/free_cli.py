from pythonosc import udp_client

# SuperCollider가 실행 중인 로컬 서버와 포트
client = udp_client.SimpleUDPClient("127.0.0.1", 57120)

# 실행할 SuperCollider 코드를 OSC 메시지로 전송
client.send_message("/runCode", '~syn.free')
