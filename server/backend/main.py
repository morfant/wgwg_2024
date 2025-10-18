# main.py

import random
import os
import re
# import json
import pprint
# from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.websockets import WebSocketState  # WebSocketState 임포트

import asyncio
# from agent import get_graph  # 에이전트 가져오기
from agent_multi import get_graph  # 에이전트 가져오기
from langchain_core.runnables.config import RunnableConfig


app = FastAPI()

# 웹소켓 클라이언트 목록
chat_clients = []  # /ws/chat에 연결된 클라이언트 목록
sc_clients = []  # /ws/sc에 연결된 클라이언트 목록

# 정적 파일 경로를 '/static'으로 설정하고, 파일들이 저장된 디렉토리를 지정
# app.mount("/static", StaticFiles(directory="static"), name="static")

# 컴파일된 그래프 가져오기
graph = get_graph()

configurable = {"thread_id": "1"}
config = RunnableConfig(configurable=configurable, recursion_limit=200)
# config = RunnableConfig(recursion_limit=100)

# FOR TEST
morse_test = False
morse_idx = 0

@app.websocket("/ws/sc")
async def websocket_sc(websocket: WebSocket):
    await websocket.accept()

    # 클라이언트에게 환영 메시지 전송
    welcome_message = {"response": "WebSocket connected!", "agentType": "Server"}
    await websocket.send_json(welcome_message)

    # 클라이언트를 목록에 추가
    sc_clients.append(websocket)
    print("sc_clients: ", sc_clients)

    try:
        while True:
            data = await websocket.receive_json()
            print("Data: \n", data)

            # "heartbeat" 메시지인지 확인
            if data.get("heartbeat") == "ping":
                continue  # "heartbeat" 메시지일 경우, 아래의 로직을 건너뜁니다.

            # 수신된 메시지 처리 비동기 작업
            asyncio.create_task(handle_sc_message(data, websocket))

    except WebSocketDisconnect:
        print("WebSocket /ws/sc connection closed")
        sc_clients.remove(websocket)

async def handle_sc_message(data, websocket: WebSocket):
    try:
        if websocket.client_state == WebSocketState.CONNECTED:
            await websocket.send_json({"response": "Processing your request..."})
    except Exception as e:
        print(f"Error sending /ws/sc message: {e}")


@app.websocket("/ws/chat")
async def websocket_chat(websocket: WebSocket):
    global morse_test

    await websocket.accept()
    chat_clients.append(websocket)  # 클라이언트 추가


    try:
        while True:
            data = await websocket.receive_json()
            print("Raw Data: ", data)

            # "heartbeat" 메시지인지 확인
            if data.get("heartbeat") == "ping":
                continue  # "heartbeat" 메시지일 경우, 아래의 로직을 건너뜁니다.

            # 버튼이나 슬라이더 메시지 처리
            if data.get("type") in ["Button", "Slider"]:
                print(f"Received {data['type']} event, broadcasting to other clients...")

                # 현재 웹소켓을 제외한 모든 클라이언트에게 브로드캐스트
                await broadcast_to_all_except_sender(websocket, data)
            else:
                # 다른 타입의 메시지도 처리 (예: 모스 코드)
                asyncio.create_task(handle_chat_message(data, websocket))

    
    except WebSocketDisconnect:
        print("WebSocket /ws/chat 연결이 종료되었습니다.")
        chat_clients.remove(websocket)  # 클라이언트 제거


async def handle_chat_message(data, websocket: WebSocket):
    global morse_idx
    try:
        response_message = ""
        partial_message = ""

        user_input = data.get("message", "")
        key = "Bot"
        message = ""    
        topic = ""
        # inputs = {"topic": topic, "messages":message, "feedback": "", "topic_changed": False } 
        inputs = {"topic": topic, "messages":message, "feedback": "", "topic_changed": False, "debate_end":False } 

        for output in graph.stream(inputs, config):
            response_message = ''
            response_morse = ''

            for key, value in output.items():
                print(f"{key}: {value}")
                if 'messages' in value:
                    for message in value['messages']:
                        response_message = message.content  

                elif 'morse' in value:     
                    for morse in value['morse']:
                        response_morse = morse.content        

            # 0 = Dot, 1 = Dash, 2 = Space
            if response_morse != '':
                morse_idx%=5
                # 리스트의 요소를 연결하고 각 요소 사이에 숫자 3 추가 : 문장 사이를 3으로 표현
                joined_string = '3'.join(response_morse)
                # print("joined_string: ", joined_string)
                for sc_client in sc_clients:
                    try:
                        if sc_client.client_state == WebSocketState.CONNECTED:
                            print("sending from messages...")
                            message = { "type": "MorseCode", "group": 100, "index": morse_idx + 1, "value": joined_string}
                            await sc_client.send_json(message)
                        else:
                            print("Client is not connected.")
                    except Exception as e:
                        print(f"Error sending message: {e}")
                morse_idx+=1 

            # 타이핑 효과를 위해, 실시간으로 클라이언트에게 부분적으로 응답을 전송
            chunk_size = 1  # 한 번에 보낼 글자의 수를 설정, 클수록 출력 빠름
            if response_message != '':
                for i in range(len(partial_message), len(response_message), chunk_size):
                    new_message = response_message[i:i+chunk_size]
                    partial_message += new_message

                    # await websocket.send_json({"response": partial_message, "agentType": key})
                    # 모든 클라이언트에 메시지 전송
                    await broadcast_to_all_chat_clients(
                        {"response": partial_message, "agentType": key}
                    )

                    await asyncio.sleep(0.02)  # 타이핑 딜레이

            partial_message = ""
      
        # # print("user_input: ", user_input)
        # # inputs = {"messages": user_input}
        # # print("inputs: ", inputs)

        # for output in graph.stream(inputs, config):
        #     # print("output:", output)
        #     # response_data = output
        #     # print(response_data)
        #     response_message = ''
        #     response_morse = ''

        #     for key, value in output.items():
        #         print(f"{key}: {value}")
        #         if 'messages' in value:
        #             for message in value['messages']:
        #                 response_message = message.content  

        #         elif 'morse' in value:     
        #             for morse in value['morse']:
        #                 response_morse = morse.content        

        #     # 0 = Dot, 1 = Dash, 2 = Space
        #     if response_morse != '':
        #         morse_idx%=5
        #         # 리스트의 요소를 연결하고 각 요소 사이에 숫자 3 추가 : 문장 사이를 3으로 표현
        #         joined_string = '3'.join(response_morse)
        #         # print("joined_string: ", joined_string)
        #         for sc_client in sc_clients:
        #             try:
        #                 if sc_client.client_state == WebSocketState.CONNECTED:
        #                     print("sending from messages...")
        #                     message = { "type": "MorseCode", "group": 100, "index": morse_idx + 1, "value": joined_string}
        #                     await sc_client.send_json(message)
        #                 else:
        #                     print("Client is not connected.")
        #             except Exception as e:
        #                 print(f"Error sending message: {e}")
        #         morse_idx+=1 

        #     # 타이핑 효과를 위해, 실시간으로 클라이언트에게 부분적으로 응답을 전송
        #     chunk_size = 1  # 한 번에 보낼 글자의 수를 설정, 클수록 출력 빠름
        #     if response_message != '':
        #         for i in range(len(partial_message), len(response_message), chunk_size):
        #             new_message = response_message[i:i+chunk_size]
        #             partial_message += new_message
        #             # print("new_message: ", new_message)
        #             # print("new_message_unicode: ", ord(new_message))
        #             await websocket.send_json({"response": partial_message, "agentType": key})
        #             # await asyncio.sleep(0.075)  # 타이핑 딜레이
        #             await asyncio.sleep(0.04)  # 타이핑 딜레이

        #     partial_message = ""
        #     await websocket.send_json({"response": "[END]", "agentType": key})

        await broadcast_to_all_chat_clients({"response": "[END]", "agentType": key})
        # await websocket.send_json({"response": "[END]", "agentType": key})

        pprint.pprint("------------------------------------")


    except Exception as e:
        print(f"WebSocket Error: {e}")
        await websocket.close()

async def broadcast_to_all_chat_clients(message: dict):
    """모든 /ws/chat 클라이언트에게 토론 메시지를 전송합니다."""
    for client in chat_clients:
        try:
            if client.client_state == WebSocketState.CONNECTED:
                await client.send_json(message)
        except Exception as e:
            print(f"Error sending message to client: {e}")
            

async def broadcast_to_all_except_sender(sender: WebSocket, data: dict):
    # Test, Button, Slider 이벤트를 ws/sc로 전달
    msg_type = data.get("type", "")

    if msg_type == "Test":
        print("Test...")
        morse_test = True

        if morse_test == True:
            # /ws/sc에 연결된 모든 클라이언트에게 메시지 전송
            for sc_client in sc_clients:
                try:
                    if sc_client.client_state == WebSocketState.CONNECTED:
                        print("sending from messages...")
                        message = { "type": "MorseCode", "group":data.get("group", 1), "index": data.get("index", 1), "value": "0120123101"}                                
                        await sc_client.send_json(message)
                    else:
                        print("Client is not connected.")
                except Exception as e:
                    print(f"Error sending message: {e}")
            morse_test = False

    elif msg_type == "Button":
        # /ws/sc에 연결된 모든 클라이언트에게 메시지 전송
        print("Button...")
        for sc_client in sc_clients:
            try:
                if sc_client.client_state == WebSocketState.CONNECTED:
                    print("sending from buttons...")
                    await sc_client.send_json(data)
                else:
                    print("Client is not connected.")
            except Exception as e:
                print(f"Error sending message: {e}")

    elif msg_type == "Slider":
        # /ws/sc에 연결된 모든 클라이언트에게 메시지 전송
        print("Slider...")
        for sc_client in sc_clients:
            try:
                if sc_client.client_state == WebSocketState.CONNECTED:
                    print("sending from sliders...")
                    await sc_client.send_json(data)
                else:
                    print("Client is not connected.")
            except Exception as e:
                print(f"Error sending message: {e}")
    
    # 브라우저 UI 동기화를 위해 broadcast
    """보낸 클라이언트를 제외한 모든 /ws/chat 클라이언트에게 메시지 전송."""
    for client in chat_clients:
        if client != sender and client.client_state == WebSocketState.CONNECTED:
            try:
                await client.send_json(data)
            except Exception as e:
                print(f"Error sending message to client: {e}")
                

# FastAPI 실행
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=4001)
