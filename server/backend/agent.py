# agent.py

import os
from typing import TypedDict
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()


# 환경 변수 설정 (필요에 따라 main.py에서 설정하는 방식과 동일하게 할 수 있음)
# os.environ["OPENAI_API_KEY"] = "your_openai_api_key"
# os.environ["LANGSMITH_API_KEY"] = "your_langsmith_api_key"
# os.environ["LANGCHAIN_PROJECT"] = "LangGraph Tutorial"

class State(TypedDict):
    messages: list

graph_builder = StateGraph(State)
llm = ChatOpenAI(model="gpt-4o")

def chatbot(state: State):
    return {"messages": [llm.invoke(state["messages"])]}

graph_builder.add_node("chatbot", chatbot)
graph_builder.add_edge(START, "chatbot")
graph_builder.add_edge("chatbot", END)

# 컴파일된 그래프 반환
def get_graph():
    return graph_builder.compile()