import getpass
import os
import pprint
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()

def _set_env(key: str):
    if key not in os.environ:
        os.environ[key] = getpass.getpass(f"{key}:")

# _set_env("OPENAI_API_KEY") #OPENAI
# _set_env("TAVILY_API_KEY") #TAVILY

#LANGCHAIN - use LangSmith for tracing
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_ENDPOINT"] = "https://api.smith.langchain.com"
# _set_env("LANGCHAIN_API_KEY")

from langchain_community.document_loaders import WebBaseLoader
from langchain.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings

#Data model
from langchain_core.messages import BaseMessage
from typing import Annotated, Sequence, TypedDict
from langchain_core.messages import BaseMessage
from langgraph.graph.message import add_messages
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field


from typing import List
from langchain_core.messages import BaseMessage
from langgraph.graph.message import add_messages

### Search
from langchain_community.tools.tavily_search import TavilySearchResults
from tavily import TavilyClient
from typing import Annotated, List
import textwrap

### LLM
from langchain_openai import ChatOpenAI
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_google_vertexai import ChatVertexAI
from langchain_community.utilities import GoogleSerperAPIWrapper
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain import hub
# from langchain.tools.retriever import create_retriever_tool

from typing import Annotated, Literal, Sequence, TypedDict
from langchain_core.messages import BaseMessage, HumanMessage
from langchain_core.prompts import PromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_core.prompts import ChatPromptTemplate

from langgraph.prebuilt import tools_condition
from langchain.schema import Document
import json
import re
from requests.exceptions import HTTPError

from langgraph.graph import END, StateGraph, START
from langgraph.prebuilt import ToolNode
from langchain_core.runnables.config import RunnableConfig


print(">> WEB LOADER")

urls = [
    "http://choomin.sfac.or.kr/zoom/zoom_view.asp?zom_idx=840&div=01&type=VW",
    "http://choomin.sfac.or.kr/zoom/zoom_view.asp?type=VW&div=&zom_idx=822&page=2&field=&keyword=",
    "http://choomin.sfac.or.kr/zoom/zoom_view.asp?type=VW&div=&zom_idx=817&page=2&field=&keyword=",
    "http://choomin.sfac.or.kr/zoom/zoom_view.asp?type=VW&div=&zom_idx=761&page=4&field=&keyword=",
    "http://choomin.sfac.or.kr/zoom/zoom_view.asp?type=IN&div=&zom_idx=839&page=1&field=&keyword=",

    "https://1000scores.com/portfolio-items/kevin-rittberger-codecode/",
    
    "https://www.corpusweb.net/a-practice-as-an-other.html",
    "https://www.corpusweb.net/performative-arts-and-the-turn-of-an-era.html",
    "https://www.corpusweb.net/meeting-yvonne-rainer.html",
    "https://www.corpusweb.net/after-dance.html",
    "https://www.corpusweb.net/-dance-like-hell.html",
    "https://www.corpusweb.net/answers-0107.html",
    "https://www.corpusweb.net/answers-0814.html",
    "https://www.corpusweb.net/answers-1521.html",
    "https://www.corpusweb.net/answers-2228.html",
    "https://www.corpusweb.net/answers-2935.html",
    "https://www.corpusweb.net/answers-3642.html",
    "https://www.corpusweb.net/answers-4349.html",
    "https://www.corpusweb.net/answer-50-en.html",
   
    "https://www.orartswatch.org/ai-wants-your-art-do-you-have-a-say/",
    "https://stedelijkstudies.com/journal/the-troubles-with-temporality/",
    "https://khio.no/en/staff/bojana-cvejic",  
    "https://www.pinabausch.org/post/what-moves-me",
    "https://www.dancehousediary.com.au/?p=4041", 
    "https://www.performancephilosophy.org/journal/article/view/29/60",
]

# LOAD WEB PAGES
docs = [WebBaseLoader(url).load() for url in urls]
docs_list = [item for sublist in docs for item in sublist]
# print(docs_list)

# LOAD PDF
print(">> PDF LOADER")    
PATH = "./data/"

pdf_files = [
    PATH + "Performative_dramaturgy_in_the_expanded_field_of_choreography.pdf",
    PATH + "Score.pdf",
    PATH + "score_of_dramaturgy.pdf",
    PATH + "the choreographic documentary glory.pdf",
    PATH + "NTTF_D.Hay.pdf",
    PATH + "Stedelijk-Studies_The-Trouble-with-Temporality_PDF-1.pdf",
    PATH + "Toward_a_Transindividual_Self_Introducti.pdf"
]

pdf_docs = []
for pdf_file in pdf_files:
    loader = PyPDFLoader(pdf_file)
    pdf_docs.extend(loader.load())

#COMBINE WEB + PDF
all_docs = pdf_docs + docs_list    

#SPLITTER
text_splitter = RecursiveCharacterTextSplitter.from_tiktoken_encoder(
    chunk_size=800, chunk_overlap=400
)

doc_splits = text_splitter.split_documents(all_docs) #WEB + PDF
# doc_splits = text_splitter.split_documents(docs_list)

# print('\n' + ">> splits size: {}".format(len(doc_splits)))
# print(doc_splits[8])

# Add to vectorDB
vectorstore = Chroma.from_documents(
    documents=doc_splits,
    collection_name="rag-chroma",
    embedding=OpenAIEmbeddings(),
)
retriever = vectorstore.as_retriever(search_kwargs={"k": 5})
print(">> VECTOR STORED")


class GradeDocuments(BaseModel):
    """Binary score for relevance check on retrieved documents."""

    binary_score: str = Field(
        description="Documents are relevant to the question, 'yes' or 'no'"
    )    

### Answer Grader
class GradeAnswer(BaseModel):
    """Binary score to assess answer addresses question."""

    binary_score: str = Field(
        description="Answer addresses the question, 'yes' or 'no'"
    )

class Review(BaseModel):
    review_note: str = Field(description="critics of the provided content, identifying any weaknesses, inaccuracies, or areas needing improvement. a numbered list detailing specific areas that require improvement, based on your critique and research findings.")
    plan: List[str] = Field(description="The step by step plan you make to accomplish user's reuquest")
    research_area: List[str] = Field(description="the list of the area that requires further research")

class initialPlan(BaseModel):
    explanation: str = Field(description="logical explanation how you set up the plan")
    plan: List[str] = Field(description="The step by step plan to accomplish user's reuquest")
    research_area: List[str] = Field(description="The research_area is the list of the area that requires further research")

class Research(BaseModel):
    # research_direction: List[str] = Field(description="groups of research instructions for each research topic to conduct in-depth research on topics")
    research_direction: str = Field(description="groups of research instructions for each research topic to conduct in-depth research on topics")
    research_area: List[str] = Field(description="The research_area is the list of the area that requires further research")

class Result(BaseModel):
    report: str = Field(description="the finalised report")


# class AgentState(TypedDict):
#     # The add_messages function defines how an update should be processed
#     # Default is to replace. add_messages says "append"
#     messages: Annotated[Sequence[BaseMessage], add_messages]


class GraphState(TypedDict):
    """
    Represents the state of our graph.

    Attributes:
        question: question
        generation: LLM generation
        web_search: whether to add search
        documents: list of documents
    """
    question: str
    generation: str
    web_search: str
    
    documents: List[str]
    archive: List[str]
    plan: List[str]
    research: List[str]
    research_direction: str

    retrieve_query: str
    retrieve_stop: str
    retrieve_count: int   


### TAVILY API
tavily_search_tool = TavilyClient(api_key=os.getenv("ENV_TAVILY_API_KEY"))

# content = client.search("What happened in the latest burning man floods?", search_depth="advanced")["results"]
# response = tavily_search_tool.search(query, search_depth="advanced", include_raw_content=True, max_results=5)["results"]


# #TAVILY - langchain
# web_search_tool = TavilySearchResults(k=5)
# results_02 = web_search_tool.invoke({"query": query})

### variables
max_retries = 5
vectorData_use = 0


#WEB SCRAPING
def scrape_webpages(urls: List[str]) -> str:
    """Use requests and bs4 to scrape the provided web pages for detailed information."""
    loader = WebBaseLoader(urls)
    docs = loader.load()
    return "\n\n".join(
        [
            f'<Document name="{doc.metadata.get("title", "")}">\n{doc.page_content}\n</Document>'
            for doc in docs
        ]
    )


###LLM
#for agent
llm_agent = ChatOpenAI(temperature=0, streaming=True, model="gpt-4o")
structured_llm_agent = llm_agent.with_structured_output(initialPlan)

system = """You are a professional assistant helping the user to find information. \n 
            Summarize the user's request, and ask them to confirm that you understood correctly.\n 
            If necessary, seek clarifying details.\n
            When the user asks or requests something, you start your response by saying "[매니저입니다.]"\n 

            1. Context Understanding:
                - First, analyze the user's request by extracting the key objectives, constraints, and desired outcomes.
                - Summarize the context in a clear and concise manner.
   
            2. Step-by-Step Plan:
                - Develop a detailed, step-by-step plan that outlines at least five distinct stages or actions needed to achieve the user's objectives.
                - Present this plan in a numbered list under the key 'plan'. 
                - Ensure that each step is actionable, logically ordered, and aligned with the user's goals.

            3. Research Areas:
                - Identify specific, detailed areas where further research or information is necessary to complete the plan.
                - Provide these in a numbered list under the key 'research_areas' and explain why each area is important.

            4. Explanation:
                - Offer a detailed explanation of logical basis and the reasoning behind the plan and the selected research areas.
                - Include the logical basis, assumptions made, and any potential challenges in at least 300 words.
                - Present this explanation under the key 'explanation'.
            
            5. Final Output:
                - 'plan': A numbered list of steps to accomplish the user's request.
                - 'research_areas': A numbered list of areas requiring further research.
                - 'explanation': A detailed explanation of the plan and research areas. it starts with "[메인 agent입니다.]"
                - Final output should be in KOREAN.

           """

#            You first understand the context of the request made by the uesr and devise a step-by-step plan with great detial to accomplish what the user request, and suggest that to users. \n 
#            
#             Return the response as a JSON object with the following structure: 
#             {
#             "plan": [List of steps to achieve the user's goal],
#             "research_areas": [List of areas that require further research]
#             }\n """

prompt = ChatPromptTemplate.from_messages(
    [
    ("system", system),
    ("human", "User question: {question}"),
    ]
)

manager = prompt | structured_llm_agent
 # model = model.bind_tools(tools)

#for critic
llm_critic = ChatOpenAI(temperature=0, streaming=True, model="gpt-4o")
structured_llm_critic = llm_critic.with_structured_output(Review)

system ="""you are a professional critic with a lot of experiences who critique the content provided by other agents and suggest better approaches or perspectives.\n 
             You are verbose and logical.\n 
             when the user ask or request something, you start response by saying "[비평 agent입니다.]\n 

            1. Critique Introduction:
                - Provide a concise summary of the content you are critiquing, focusing on the key points and context.

            2. Critique Details:
                - Offer a thorough critique of the provided content, identifying specific weaknesses, inaccuracies, or areas needing improvement.
                - Make sure your critique is well-structured, with distinct sections covering different aspects (e.g., logical coherence, factual accuracy, effectiveness of communication).
                - Each section should include specific, actionable suggestions for improvement.
                - Aim for clarity and depth in your critique, with a word count of around 300-500 words. This range allows for thoroughness without unnecessary verbosity.

            3. Revised Plan:
                - Based on your critique, create a revised step-by-step plan that integrates the suggested improvements.
                - Ensure the plan is detailed, with clear and actionable steps that address the identified issues.
                - The plan should be well-organized, following a logical order that the user can easily follow.
                - Keep the plan concise, aiming for 300-500 words to maintain focus and clarity, while providing enough detail for implementation.

            4. Research Areas:
                - Based on your critique, analyze the given research area and Identify and update at least 8 distinct areas that require further research to successfully implement the revised plan.
                - Ensure that each area is specific, actionable, and directly tied to the improvements suggested in the critique.
                - Provide a brief explanation for each area, highlighting why it is crucial for the success of the plan.
                - Avoid the use of demonstrative pronouns; instead, use explicit proper nouns for clarity and precision.
                - Present these areas in a numbered format under the key 'research_areas'.
                
            5. Final Output:
                - Format the final output in the following structure:
                    - 'review_note': A detailed analysis of the provided content, with actionable suggestions for improvement.
                    - 'plan': A revised, step-by-step plan incorporating the suggested improvements.
                    - 'research_areas': A numbered list of areas requiring further research, with explanations for each.
                - Final output should be in KOREAN.    

            """
            # 6. Feedback and Iteration**:
            #     - If the user provides feedback on the critique or plan, incorporate it into an updated version.
            #     - Always confirm with the user if the revisions meet their expectations or if further adjustments are needed.
  
# system ="""You are a professional critic with extensive experience in evaluating content provided by other agents, offering better approaches or perspectives. 
#             You are concise and logical. 
#             When the user asks or requests something, start the response by saying "[비평 agent입니다.]" 

#             Critique the provided content, identifying any weaknesses, inaccuracies, or areas needing improvement. This critique should be at least 500 words long, with specific, actionable suggestions.'
#             Then, Based on your critique, create a revised step-by-step plan that incorporates the suggested improvements. The plan should be detailed, with clear action items, and be at least 500 words long with the key 'plan'. 
#             Update the list of areas requiring further research in a numbered format with the key 'research_area'. 
            
#             Ask the user whether to share the revised plan and research areas with other agents, or allow the user to automatically share based on predefined conditions.
#             """

#test for JSON
# system = """you are a professional critic with a lot of experience who critiques the content provided by other agents and suggests better approaches or perspectives. 
#             You are verbose and logical. 
#             When the user asks or requests something, you start the response by saying "[비평 agent입니다.]" 

#             You critique the provided content, identifying any weaknesses, inaccuracies, or areas needing improvement, this review note shoud be at least 500 words long. 
#             Create a numbered list detailing specific areas that require improvement, based on your critique and research findings.this shouldbe at least 300 words long and  this should be included in review note.
#             please return review note in JSON format with the key 'review_note' and it should be string
#             you revise the initial plan to include more detailed and specific suggestions for the research areas, according to the improvements you have identified. Ensure the revised plan is at least 300 words long.
#             please return revised plan  in JSON format with the key 'plan' it shoud be the list of string
#             You also revise the list of areas that require further research in a numbered format. please return the list of areas in JSON format with the key 'research_area
#             you ask the user whether you share your revised plan and the list of areas that require further research in a numbered format with other agent. """

# ciritic_prompt = ChatPromptTemplate.from_messages(
#     [
#         ("system", system),
#         ("human", "message:\n\n {message} plan:\n\n {plan} \n\n question: {question}"),
#     ]
# )

ciritic_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "plan:\n\n {plan} \n\n research area: {research} \n\n question: {question}"),
    ]
)

# critic = ciritic_prompt | llm_critic
critic = ciritic_prompt | structured_llm_critic


### for research director
llm_research_director = ChatOpenAI(temperature=0, streaming=True, model="gpt-4o-2024-08-06")
# llm_researcher = ChatOpenAI(temperature=0, streaming=True, model="gpt-4o")

structured_llm_research_director = llm_research_director.with_structured_output(Research)

# system = """you are an experienced research director on various areas such as art, science and other fields.\n 
#             You find useful information to give an answer to the users.\n 
#             You are verbose and logical.\n 
#             when the user ask something you start by saying "[리서치 agent입니다.]",and summarize the request you've received.\n

#             First, analyze the user's request by extracting the key objectives, constraints, and desired outcomes.
#             identify specific areas to conduct detailed research based on the content you are given, make a numbered list of these areas. and show it to the user.and show it to the user under the key 'research'.\n
#             When you finish research on certain item on the list, present findings to the the user in at least 300 words and proceed with research on the next item on the list.\n 
#             After finishing all the research on items on the list, you summarize your findings in at least 700 words, offering insights into various aspects of the topic.\n
#             The summarization you provide should be formatted in markdown, with appropriate use of headings and bullet points for easy navigation and readability.\n """

system_00 = """You are an experienced research director specialized in improving and optimizing research areas for academic inquiry and effective web search, as well as in designing clear and logical research directions that guide researchers efficiently to efficiently gather relevant information, analyze data, and achieve meaningful results.   
            when the user ask something you start by saying "[리서치 디렉터 agent입니다.]",and summarize the request you've received.
            
            1.You analyze the critique: {plan} thoroughly, and then modify the provided research topics: {research} based on your analysis for better version that is highly optimized for search engine. Your goal is to create clearer, more specific research topics that align with the user's original request and research objectives. 
                                                                                                                                                                                                                                             
                - Extract the key objectives, constraints, and outcomes from the provided plan {plan}.
                - Modify each research topic by incorporating relevant keywords and phrases, replacing vague language with specific terms, and aligning them with the overall goals.
                - Ensure that each research topic is precisely aligned with the overall research goals, emphasizing clarity, specificity, and relevance.
                - **Optimize each research area for web search** by incorporating relevant keywords, phrases, and search-friendly structures. This will facilitate more effective information retrieval during the research process.
                    - Replace any vague language or demonstrative pronouns with explicit proper nouns and detailed, descriptive terms. This ensures that each research area is clear, specific, and unambiguous.
                - Present the revised list clearly under the key 'research_area'.

            2.create research instructions for a Research Agent to research the revised research topics  
                - Conduct in-depth analyses of all the topics on the revised list one by one.
                - As a Research Director, your task is to create clear and comprehensive research instructions for a Research Agent related to the topics. When generating these instructions, ensure that the research process is structured and covers all necessary aspects. 
                Use the following framework to develop your instructions:

                     - Heading: 
                        Clearly state the research topic at the beginning of the prompt. Ensure the topic is prominently displayed.   

                    - 1.Overview and Context:
                        Instruct the Research Agent to start with a brief summary of the topic, explaining its significance and relevance. Ensure they provide any necessary background information that sets the context for the research.
                    
                    - 2.Critical Questions and Key Points:
                        Guide the Research Agent to identify and address at least five critical questions central to the topic. These questions should drive the research and highlight the key themes or issues that need to be explored.

                    - 3.Key Quotes, Passages, and Data:
                        Ask the Research Agent to extract and present at least five important quotes, passages, or data points relevant to the topic. They should clearly explain the significance of each piece of evidence.

                    - 4.Additional Considerations:
                        Remind the Research Agent to highlight any additional factors that should be considered, such as ethical concerns, historical context, social cliamte, contemporary trends, cultural significance, the medium's characteristics, and impact on enviroment.
                        This section should ensure a well-rounded approach to the topic by addressing these crucial elements that influence the subject matter.

                    - 5.References:
                        Instruct the Research Agent to compile a list of references or citations that should be included in the research. Ensure they follow proper citation formats and provide a comprehensive list of sources.  

                    - 6.Further Questions:
                        Encourage the Research Agent to list any additional questions that arise naturally from the topic. These questions should help refine the research focus or guide future exploration.    
                    
                    - 7.Potential Information Sources:
                        Direct the Research Agent to identify and recommend specific sources that will be useful for the research. Ensure that they include a variety of credible resources (e.g., books, articles, databases) and explain why each source is valuable.
                        Guide the Research Agent to provide the context of recommended sources. 

                    Use this structure to create a clear and organized set of instructions for the Research Agent. Ensure that each section is detailed enough to guide them through the research process effectively.

                - For instructions for **each** research topic:
                    - Present guidance and instruction on each research topic in a well-structured report of at least 1000 words, ensuring that the instruction follows a directive format to guide the research process.
                    - Use markdown formatting for clarity, including appropriate headings, bullet points, and other elements to enhance readability.
                        - Number all sections and subsections to provide a clear and organized structure.  

                - After completing the instruction on each topic, **automatically proceed** to the next topic in the list.\n
                - Present these instructions in a numbered format under the key 'research_direction'. it starts with "[리서치 디렉터 agent입니다.]
                - Final output should be in KOREAN.    
                """

                # - Present guidance and instruction on each research topic in a well-structured report of at least 1000 words, ensuring that the instruction follows a directive format to guide the research process under the key 'research_direction.'

system_01 = """You are an experienced research director specialized in improving and optimizing research areas for academic inquiry and effective web search, as well as in designing clear and logical research directions that guide researchers to efficiently gather relevant information, analyze data, and achieve meaningful results.
            when the user ask something you start by saying "[리서치 디렉터 agent입니다.]",and summarize the request you've received.
            output should be in English.  
            
            1.you analyze and revise the provided research topics {research} based on the input plan and critique {plan}. Ensure the revised research topics are highly optimized for search engines, clear, specific, and aligned with the research goals.
                - Extract the key objectives, constraints, and outcomes from the provided plan {plan}, and revise each research topic based on guidances from {plan}.
                - Using the insights from the review note, systematically revise and enhance each research item in the 'research area' {research} by incorporating relevant keywords and phrases, replacing vague language with specific terms, and aligning them with the overall goals.
                - Ensure that each research topic is precisely aligned with the overall research goals, emphasizing clarity, specificity, and relevance.
                - **Optimize each research area for web search** by incorporating relevant keywords, phrases, and search-friendly structures. This will facilitate more effective information retrieval during the research process.
                    - Replace demonstrative pronouns with explicit proper nouns and detailed, descriptive terms. This ensures that each research area is clear, specific, and unambiguous.
                - Present the revised list clearly under the key 'research_area'.

            2.Develop a comprehensive and detailed prompt for a Research Agent to investigate all topics in the revised research list. Ensure that all topics are addressed one by one and that the research instructions are structured and cover necessary aspects. Follow these steps for each topic:
            
                1.Heading: 
                Clearly state the research topic at the beginning of the prompt. Ensure the topic is prominently displayed.   

                2.Instructions: 
                For each topic, Use the following framework to develop your instructions:

                    - 1.Overview and Context:
                        Instruct the Research Agent to start with a brief summary of the topic, explaining its significance and relevance. Includeany necessary background information that sets the context for the research.
            
                    - 2.Critical Questions and Key Points:
                        Guide the Research Agent to identify and address at least five critical questions central to the topic. These questions should drive the research and highlight the key themes or issues that need to be explored.

                    - 3.Key Quotes, Passages:
                        create prompt for the Research Agent to extract and present at least five important quotes, passages, or data points relevant to the topic. Clearly explain the significance of each piece of evidence.
                    
                    - 4.Additional Considerations:
                        Remind the Research Agent to highlight any additional factors and perspectives that should be considered, such as ethical concerns, historical context, or current trends. This ensure a well-rounded approach to the topic.    

                    - 5.Analysis and Synthesis:
                        Guide the Research Agent to synthesize the gathered information into a cohesive narrative or argument, ensuring the research forms a clear and logical structure.
                            
                    - 5.References:
                        Instruct the Research Agent to compile a list of references or citations that should be included in the research. Ensure they follow proper citation formats and provide a comprehensive list of sources.
                
                    - 6.Further Questions:
                        Encourage the Research Agent to list any additional questions that arise naturally from the topic. These questions should help refine the research focus or guide future exploration.

                    - 7.Find potential Information Sources:
                        create instruction for the Research Agent to find specific sources that will be useful for the research. Ensure that they include a variety of credible resources (e.g., books, articles)

                    - Use bullet points and lists to enhance readability and clarity. Ensure that the instructions are directive and facilitate a structured research process.    

                3.Create:
                the instructions on each research topic should be at least 500 words in length, ensuring that the instruction follows a directive format to guide the research process.  

                4.Proceed to Next Topic: 
                After completing the research instructions for one topic, automatically proceed to the next topic in the revised list. Ensure that all topics are covered.

                5.Group Instructions:
                Once all prompts are created for each research topic, all instructions should be grouped together corresponding to each topic, and stored under the key 'research_direction'."""                
                
                                
system_02 = """You are an experienced research director specialized in improving and optimizing research areas for academic inquiry and effective web search, as well as in designing clear and logical research directions that guide researchers efficiently to efficiently gather relevant information, analyze data, and achieve meaningful results.".\n
            when the user ask something you start by saying "[리서치 디렉터 agent입니다.]",and summarize the request you've received.\n
            
            1.you analyze and revise the provided research topics {research} based on the input plan and critique {plan}. Ensure the revised research topics are highly optimized for search engines, clear, specific, and aligned with the research goals.
                - Extract the key objectives, constraints, and outcomes from the provided plan {plan}.
                - Revise each research area by incorporating relevant keywords and phrases, replacing vague language with specific terms, and aligning them with the overall goals.
                - Ensure that each research item is precisely aligned with the overall research goals, emphasizing clarity, specificity, and relevance.
                - **Optimize each research area for web search** by incorporating relevant keywords, phrases, and search-friendly structures. This will facilitate more effective information retrieval during the research process.
                    - Replace any vague language or demonstrative pronouns with explicit proper nouns and detailed, descriptive terms. This ensures that each research area is clear, specific, and unambiguous.
                - Present the revised list clearly under the key 'research_area'.

            2.conduct analysis of the revised research topics and create detailed research guidance
                - Conduct an in-depth analysis of all the topics on the revised list one by one. 
                - The goal is to create detailed and comprehensive guidance and prompts for the research agent to conduct effective research. 
                - For **each topich**,The detailed research guidance for the research agent should include **detailed exploration and intruction for reseaching **each topic** that outlines the key research focus to be researched like the following sections: 
                    - 1) Overview and Context: provide a brief summary of the topic, its significance, and any relevant background information.
                    - 2) Critical Questions and Key Points: Identify at least five main questions that should be answered when researching the topic. Highlight key issues or themes that need to be addressed.
                    - 3) Finding potential information sources: find specific sources that would be useful for researching the topic, such as books, articles, databases, interviews, or other relevant materials.
                    - 4) Key Quotes, Passages and Data from the topic: extract at least five important quotes, passages, or data from the topic.
                    - 5) references: provide a list of any references or citations that should be included in the research.
                    - 6) Additional Considerations for the topic: highlight any additional factors that should be taken into account when researching the topic, such as ethical concerns, historical context, or current trends.
                    - 7) Questions that come to mind about the topic: List any questions that naturally arise from the topic, which could guide further exploration or clarify the research objectives.

                - Present guidance and instruction on each research topic in a well-structured report of at least 1000 words under the key 'research_direction', instruction for each topic is saved seperately in the list of string ensuring that the report follows a directive format to guide the research process.
                - Use markdown formatting for clarity, including appropriate headings, bullet points, and other elements to enhance readability.
                    - Number all sections and subsections to provide a clear and organized structure.  
                - After completing the research on each topic, **automatically proceed** to the next topic in the list.
                - Final output should be in English.  
                """

system_03 = """You are an experienced researcher on various areas such as art, science and other fields.\n 
            You find useful information to give an answer to the users.\n 
            You are verbose and logical.\n 
            when the user ask something you start by saying "[리서치 agent입니다.]",and summarize the request you've received.\n

            1. revise and enhance research areas list:
                - Begin by carefully analyzing an input plan provided by critic. Clearly identify and extract the key objectives, constraints, and desired outcomes as outlined in the critique. \n
                - Leverage the insights from the review note to systematically revise and enhance each research item on the input research area list \n
                - after revision of the list, Present the list to the user under the key 'research_area'
                - **Optimize each research area for web search** by incorporating relevant keywords, phrases, and search-friendly structures. This will facilitate more effective information retrieval during the research process.\n
                - Ensure that these revisions are closely aligned with the feedback provided by the critic agent and the overarching research goals.\n
                - Ensure that each research item is precisely aligned with the overall research goals, emphasizing clarity, specificity, and relevance.\n
                - Replace any vague language or demonstrative pronouns with explicit proper nouns and detailed, descriptive terms. This ensures that each research area is clear, specific, and unambiguous.\n
                
            2. conduct analysis of the research item : 
                - Conduct an in-depth analysis of all the items on the revised list one by one. \n
                - The analysis for each item should include **detailed exploration** that outlines the key questions to be answered like the following sections: 1) Description, 2) Key Points 3)potential sources of information and 4) methodologies.
                - For **each** research item:
                    - Present findings on each research area in a well-structured report of at least 300 words under the key 'research_result' .
                    - Use markdown formatting for clarity, including appropriate headings, bullet points, and other elements to enhance readability. \n
                - After completing the research on each item, **automatically proceed** to the next item in the list.\n
                - After finishing research on all items on the list, you summarize all your findings in at least 500 words under the key 'summary', offering insights into various aspects of the topic \n
                - The summarization you provide should be formatted in markdown, with appropriate use of headings and bullet points for easy navigation and readability.\n 

            3. final Output:
                 - Organize the final output with the following structure:
                     - 'research_area': a numbered list of research areas revised based on the critic agent's feedback under the key 'research_area'.
                     - 'research_result': detailed reports on each research area, presented as research is completed under the key 'research_result'.
                     - 'summary': findings in a well-structured report of at least 500 words under the key 'summary'
                - Final output should be in English.     
            """

            ### LEFTOVERS   
            # - For each topic, provide detailed guidance and prompts for effective research. This should include specific steps, key questions to address, and potential challenges to be aware of.
            # - The goal is to conduct a comprehensive analysis of the revised research topics, ensuring thorough exploration and guidance on researching each topic.
            # Your task is to design a clear and logical research direction that guides researchers to efficiently gather relevant information, analyze data, and achieve meaningful results."
            #- Present the revised list to the user under the key 'research_area', ensuring that each item is well-defined, actionable, and ready for in-depth investigation.    \n
            # - when you finish research on all the area, present them  under the key 'content'. \n  
            #- The analysis for each item should include the following sections: 1) Description, 2) Key Points, 3) Conclusion and Recommendations.
            

            # 1. Revise and Enhance Research Areas:
            #     - Begin by thoroughly analyzing the review note provided by the critic agent, clearly identifying and extracting the key objectives, constraints, and desired outcomes outlined in the critique. Summarize these elements to ensure a clear understanding of the feedback.
            #     - Using the insights from the review note, systematically revise and enhance each research item in the 'research area' list.
            #     - For each research area, address specific suggestions, critiques, and insights provided by the critic agent. This includes identifying any gaps, leveraging strengths, and exploring opportunities for improvement.
            #     - Clearly define and expand upon each research area to ensure greater precision and depth, making sure each item is aligned with the overall research objectives.
            #     - Replace any vague language or demonstrative pronouns with explicit proper nouns and detailed descriptions to maintain clarity and specificity. 
            #     - each research area should also be optimized for web search
            #     - Consider potential implications or challenges mentioned by the critic agent, and refine the research areas to address these proactively.
            #     - Organize the revised research areas into a logically ordered, numbered list. Ensure that this list reflects the enhanced focus, clarity, and alignment with the research goals.
            #     - Present the finalized list to the user under the key 'research_area', ensuring that each item is detailed, actionable, and aligned with the objectives provided by the critic agent.


            # 1. Revise Research Areas:
            #     - Thoroughly analyze the review note provided by the critic agent, clearly identifying the key objectives, constraints, and desired outcomes outlined in the critique.
            #     - Based on the detailed feedback from the critic agent, revise and enhance each research item in the 'research area' list.
            #     - Focus on addressing specific suggestions, critiques, and insights mentioned in the review note, aiming to improve clarity, focus, and alignment with the overall research objectives.
            #     - Clearly define each research area, ensuring that all gaps, strengths, or opportunities identified by the critic agent are taken into account.
            #     - Avoid the use of demonstrative pronouns; instead, use explicit proper nouns for clarity and precision.
            #     - Create a numbered list of these revised research areas and present it to the user under the key 'research_area'.

            # #4. Summary of Findings:
            #     - After completing research on **all** items, provide a comprehensive summary of your findings in at least 700 words.
            #     - Format the summary in markdown for easy navigation and readability, using headings, bullet points, and other markdown elements to organize the content effectively.
            #     - This summary should synthesize the information gathered across all research areas, offering insights into various aspects of the topic.
            #     - A markdown-formatted summary of all findings, with clear headings and bullet points for easy navigation.

            #- Prioritize the revised research areas based on criteria such as relevance to key objectives, potential impact, and feasibility.
            # - Summarize these elements concisely to guide the revision of your research approach, ensuring that the summary reflects an understanding of the critic agent's insights and priorities.
            #  
            # - Ensure that each research area is clearly defined and directly relevant to the user's objectives.
            # - Prioritize the research areas based on their importance to the overall objectives and present this prioritized list to the user.

            # 5.Feedback and Iteration:
            #     - Incorporate any feedback from the user at each stage of the research process.
            #     - Adjust the research focus, order, or depth based on the user’s feedback to ensure that the final results are aligned with their needs.


research_director_prompt = ChatPromptTemplate.from_messages(
    [
    ("system", system_00),
    ("human", "critique about the initial plan: {plan} \n\n research topics from critic: {research}"),
    ]
)

research_director = research_director_prompt | structured_llm_research_director

### for researcher
llm_researcher = ChatOpenAI(temperature=0, streaming=True, model="gpt-4o-2024-08-06")

system_01 ="""You are an experienced researcher specialized in finding userful information. 
        when the user ask something you start by saying "[리서치 agent입니다.]".

        The output shoud be in KOREAN.

        1.Research instruction and Topic:
            - Identify the content related to the research topic {research} within the input {research_direction}. Based on the identified content, determine the research instructions corresponding to the research topic. Then, identify the specific objectives and areas to conduct detailed research based on the research instructions.

        2.Search for Relevant Information:
            - MUST Follow the instructions to conduct a thorough and structured research on the assigned topic. Adhere to the guidelines for each section to ensure all aspects of the research are covered comprehensively.
            - Must avoid simply restating or elaborating on the instructions. Instead, focus on gathering new, relevant information that adds value to the research.
            - Actively find useful information from credible sources such as academic journals, books, interviews, article, news, and case studies that are directly related to {research} by using Tavily web_serach_tool.
            - Extract and present relevant data, quotes, and examples. Ensure that the information directly supports the objectives outlined in the instructions.
            
        3.Additional Tasks:
            - Find 5 academic sources (e.g., journals, articles) that provide insights into the intersection of technology and human perception, and present the context of them.
            - Find and summarize 5 interviews related to the topics that offer additional perspectives, and present the context of them.
            - Incorporate at least 5 reviews or critiques about the topic to understand its reception and contributions, and present the context of them.
            - Extract and present key quotes, passages, and case studies that directly relate to the topic.
            - All results from additional tasks under the key 'additional information'.

        4.Generate Queries:
            - Create appropriate search queries based on your summarization to help the user easily find additional information on the web under the key 'query'.
        
        5.Output:
            - Provide a detailed 1000 words report that includes all relevant information, quotes, and analysis. Ensure that the findings are integrated into a cohesive narrative that aligns with the research topic.
            """

system_02 ="""You are an experienced researcher specialized in finding userful information. \n
        when the user ask something you start by saying "[리서치 agent입니다.]".\n
       
        1.Research Direction and Topic:
            - You first identify the reseach direction within {research_direction} corresponding to the research topic {research} provided.

        2.Search for Relevant Information and Present It:
            - You understand the context of the research diretion about the research topic to clarify the reserach task.  
            - Next, conduct actual research about the research topic {research} according the specified research task for {research}, finding relevant information, locating credible sources and integrating them into the report. 
            - Make sure to adhere closely to the guidelines and objectives outlined in {research_direction} for the given research topic {research}. In particular, 'Potential Information Sources' section, please do conduct in-depth research by investigating the suggested information sources and incorporate the findings into the report. 
            - Provide a well-structured and comprehensive report of a minimum of 3000 words requiring a comprehensive and organized presentation of the findings in response to the specified research direction.
            - Present it in English to the user under the key 'research result'.
       
        3.Generate Queries:
            - Create appropriate search queries based on your summarization to help the user easily find additional information on the web under the key 'query'.\n
        """

        ### LEFTOVER
        # - Next, conduct actual research according to the identified direction, finding relevant sources and reflecting them in the report, ensuring that you follow the guidelines and objectives outlined in {research_direction} corresponding to the research topic {research} provided.
        # - Based on the user's input, summarize the research direction and topic to clarify the task, and present it to the user.
        # - Find relevant information on the given research topic {research} according to the research direction {research_direction}, your findings in at least 500 words, offering insights into various aspects of the topic.

researcher_prompt = ChatPromptTemplate.from_messages(
    [
    ("system", system_01),
     ("human", "The research directions you need to follow as prompts when conducting research: {research_direction} \n\n the research topic is this: {research} \n\n original user's question:{question}"),
    ]
)

researcher = researcher_prompt | llm_researcher

###for grader
# llm_grader = ChatOpenAI(temperature=0, model="gpt-4-0125-preview")
llm_grader = ChatOpenAI(temperature=0, model="gpt-4o-2024-08-06")

structured_llm_grader = llm_grader.with_structured_output(GradeDocuments)

# Prompt
system = """You are a grader assessing relevance of a retrieved document {documents} to input query {retrieve_query}.\n 
If the document contains keyword(s) or semantic meaning related to the question, grade it as relevant.\n
It does not need to be a stringent test. The goal is to filter out erroneous retrievals.\n
Give a binary score 'yes' or 'no' score to indicate whether the document is relevant to the question.\n
"""

grade_prompt = ChatPromptTemplate.from_messages(
    [
    ("system", system),
    ("human", "Retrieved document: \n\n {documents} \n\n input query:: {retrieve_query}"),
    ]
)

retrieval_grader = grade_prompt | structured_llm_grader

###for Querry Re-writer
llm_rewriter = ChatOpenAI(model="gpt-4o", temperature=0)

# Prompt
system = """You are a query re-writer that converts an input query {retrieve_query} into a better version that is optimized for web search. \n 
            In addition, modify the query to ensure it appropriately addresses the user's original question {question} and intent for a more accurate and relevant search result.\n 
            Look at the input and try to reason about the underlying semantic intent / meaning."""

re_write_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        (
            "human", "Here is the original question from the user: \n\n {question} \n\n and query for web search {retrieve_query} Formulate an improved query.",
        ),
    ]
)

question_rewriter = re_write_prompt | llm_rewriter | StrOutputParser()

### for generater - NOT USING AT THE MOMENT
prompt = hub.pull("rlm/rag-prompt")
llm_generate = ChatOpenAI(model_name="gpt-3.5-turbo", temperature=0, streaming=True)
# llm = ChatOpenAI(model_name="gpt-4o", temperature=0, streaming=True)
# Chain
rag_chain = prompt | llm_generate | StrOutputParser()


### for cleaner
llm_cleaner = ChatOpenAI(model="gpt-4o-mini", temperature=0)

system = """You will receive raw content extracted from web sources {web_results}. Your task is to clean and refine this content while ensuring that key details and important information are retained. Follow these steps:

            - Remove Unnecessary Content: Eliminate any advertisements, irrelevant details, or repeated information that does not contribute to the core message.
            - Summarize and Organize: Reorganize the content logically, ensuring it flows coherently. Summarize lengthy passages where necessary, but do not oversimplify. Keep essential details intact.
            - Enhance Readability: Ensure the refined content is easy to read and understand. Break down complex information into simpler sentences or bullet points if needed, while maintaining the integrity of the information.
            - Keep the Context: Make sure the refined content maintains the original context and purpose of the web-sourced material.
            - Output: Provide the cleaned and refined content, ready for use in further processing or analysis."""

cleaner_prompt = ChatPromptTemplate.from_messages(
    [
    ("system", system),
    ("human", "here is the web resources: {web_results}"),
    ]                                
)

cleaner = cleaner_prompt | llm_cleaner

### for writer & analyst
## GEMINI
llm_reporter_gemini = ChatGoogleGenerativeAI(model="gemini-1.5-pro",
      google_api_key=os.getenv("ENV_GOOGLE_GEMINI_API_KEY"),
      convert_system_message_to_human = True,
      verbose = False,
)

# structured_llm_reporter_gemini = llm_reporter_gemini.with_structured_output(Result)

# llm=ChatGoogleGenerativeAI(model="gemini-1.5-pro", temperature=0.7, google_api_key=os.getenv('GOOGLE_API_KEY'))
# llm_reporter_gemini = ChatVertexAI(model="gemini-1.5-pro",temperature=0, max_tokens=None,max_retries=6,stop=None,)

### OPENAI
# llm_reporter = ChatOpenAI(model="gpt-4o-2024-08-06", temperature=0)
# llm_reporter = ChatOpenAI(model="gpt-4o-mini", temperature=0) #MINI
# structured_llm_reporter = llm_reporter.with_structured_output(Result)

system_01 = """You are an experienced analyst on various areas such as art, science and other fields.\n 
            Your sole purpose is to write well written, critically acclaimed objective and structured reports on the given archive.
            You find useful information to give an answer to the users.\n 
            You are verbose and logical.\n 
            when the user ask something you start by saying "[분석 agent입니다.]",and summarize the request you've received.
            Take a deep breath and take it step by step to provide an insightful response.

            you analyze {archive} that you are given and answer the following user's question: {question} in a detaied, well-structured, comprehensive anlaysis of minimum 5000 words that offers in-depth insights into various aspects of the archive {archive}. 
                - Analyze the provided archive and categorize it according to the context.
                - Summarize it and develop a series of thoughtful and detailed questions related to the each category, then carefully answer each question. Use this process of self-reflection to deepen your understanding and arrive at a more accurate and well-rounded conclusion.
                - Do not oversimplify. Keep essential details intact when you summarize.
                - You make a comprehensive judgement based on all the answer to formulate the conclusion.
                - You explain the logical basis on which you reached that conclusion in a numbered format.
                
                - Structure your report in numbered sections,reflecting your expertise in art, science, and other relevant areas with appropriate use of headings and bullet points for easy navigation and readability.
                - You MUST present key quotes, passages, and case studies that directly relate to the topic.
                - you MUST provide potential information to look at. if possible, provide the context of them and the links
                - you MUST provide at least 10 questions that come to mind about the topic: List any questions that naturally arise from the topic, which could guide further exploration or clarify the research objectives.
                - you MUST provide detailed references in MLA format and markdown syntax.

            present your analysis under the key 'result'   
            Final output should be in KOREAN.     
            """ 

system_02 = """ You are an experienced analyst on various areas such as art, science and other fields.\n 
            Your sole purpose is to write well written, critically acclaimed objective and structured reports on given text.
            You find useful information to give an answer to the users.\n 
            You are verbose and logical.\n 
            when the user ask something you start by saying "[분석 agent입니다.]",and summarize the request you've received.
            
            Analyze the provided archive {archive} and answer the user’s question: {question} in a detailed, well-structured, and comprehensive report of at least 4000 words. The report should offer in-depth insights into various aspects of the archive, ensuring that each section contributes meaningfully to the overall analysis.
                1.Question Development and Self-Reflection: Formulate a series of thoughtful, detailed questions related to the subject. Then, answer each question thoroughly, using this self-reflective process to deepen your understanding and enhance the accuracy of your conclusions.
                2.Comprehensive Judgment and Conclusion: Synthesize all your answers to make a well-rounded judgment. Ensure your conclusion reflects a balanced consideration of all aspects, and avoid oversimplification while maintaining essential details.
                3.Structured Report: Organize your report into numbered sections, clearly demonstrating your expertise in art, science, or other relevant areas. Use appropriate headings, bullet points, and subheadings for easy navigation and readability. Ensure that each section contributes to meeting the word count requirement by thoroughly exploring different angles.
                4.Logical Explanation: Provide a numbered breakdown of the logical basis for your conclusions. Clearly explain the reasoning behind each key point and conclusion, making sure to elaborate on all necessary details to achieve the target word count.
                5.Further Exploration: Suggest potential information to explore further, including additional resources or perspectives that might enrich the analysis.
                6.Questions for Future Research: List any additional questions that naturally arise from the topic, which could guide further exploration or clarify the research objectives.
                7. Detailed References: Provide thorough references in MLA format, using markdown syntax. Ensure that citations are comprehensive and well-organized, supporting your analysis with credible sources.
            
            Final output should be in English.
            """
            ### LEFTOVERS
            #- You must break down your report into various detailed questions to draw a more accurate conclusion.

reporter_prompt = ChatPromptTemplate.from_messages(
    [
    ("system", system_01),
    ("human", "plan: \n\n {plan} \n\n archive: {archive} \n\n original user's question: {question}"),
    ]                                
)

### GPT-4O
# reporter = reporter_prompt | llm_reporter
# reporter = reporter_prompt | structured_llm_reporter

### GEMINI 1.5PRO
reporter = reporter_prompt | llm_reporter_gemini
# reporter = reporter_prompt | structured_llm_reporter_gemini

### for publisher - NOT USING AT THE MOMENT
llm_analysis = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
structured_llm_grader = llm_analysis.with_structured_output(GradeAnswer)

# Prompt
system = """You are a grader assessing whether an answer addresses / resolves a question \n 
     Give a binary score 'yes' or 'no'. Yes' means that the answer resolves the question."""

answer_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_01),
        ("human", "User question: \n\n {question} \n\n LLM generation: {generation}"),
    ]
)

answer_grader = answer_prompt | structured_llm_grader


### Nodes
def agent(state):
    """
    Invokes the agent model to generate a response based on the current state. Given
    the question, it will decide to retrieve using the retriever tool, or simply end.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New key added to state, documents, that contains retrieved documents
    """

    # START
    print('\n' + ">> AGENT START")
    question = state["question"]
    response = manager.invoke({"question": question})

    # print(response)
    # print('\n' + ">> manager: {}".format(response.content))

    wrapped_explanation = textwrap.fill(response.explanation, width=80)
    # wrapped_plan = textwrap.fill(response.plan, width=70)
    # wrapped_research_area = textwrap.fill(response.research_area, width=70)
    print('\n' + ">> 설명: {}".format(wrapped_explanation)) 
    # print(">> 설명: {}".format(response.explanation))
    print('\n' + ">> 실행 계획: {}".format(response.plan))
    print('\n'+ ">> 리서치 영역: {}".format(response.research_area))

    # print(">> 실행 계획: {}".format(wrapped_plan))
    # print(">> 리서치 영역: {}".format(wrapped_research_area))

    # parsed_response = parse_response(response)
    # print(parsed_response)
    
    return {"question": question, "plan": response, "research": response.research_area}
    # return {"messages": [response]}


def review(state):
    print('\n' + ">> REVIEW THE PLAN")

    plan = state["plan"]
    reserach_area = state["research"]
    question = state["question"]

    # print('\n' + ">> from AGENT: {}".format(plan))

    # response = critic.invoke({"message": "Please respond in JSON with `plan` and `research_area` keys.", "plan": plan, "question": question})
    response = critic.invoke({"plan": plan, "research": reserach_area, "question": question})
    # response = critic.invoke({"message": "respond in JSON with `plan` and `research_area` keys", "plan": plan, "question": question})
    # print('\n' + ">> critic: {}".format(response.content))

    wrapped_review_note = textwrap.fill(response.review_note, width=80)
    
    print('\n'+ ">> 리뷰 노트: {}".format(wrapped_review_note))
    print('\n'+ ">> 계선된 계획: {}".format(response.plan))
    print('\n'+ ">> 기존 리서치 영역: {}".format(reserach_area))
    print('\n' + ">> 개선된 리서치 영역: {}".format(response.research_area)+ '\n')

    # print(response[0])
    #review_note = response.review_note
    revised_plan = ''.join(response.plan) + response.review_note
    further_research_area = response.research_area
    
    research = further_research_area
    # print(">> 전체 리서치 영역: {}".format(research))

    return {"plan": response, "question": question, "research":research }


### for research director
def research(state):
    print('\n' +">> RESEARCH DIRECTOR")
    plan = state["plan"]
    question = state["question"]
    research = state["research"]
    archive = state["archive"]
    research_direction = state["research_direction"]

    retry_count = 0
    success = False

    # print(">> 리서치 계획 from 비평agent: {}".format(plan))
    while not success and retry_count < max_retries:
        try:
            response = research_director.invoke({"plan": plan, "research": research, "question": question})
            success = True  # 요청 성공 시 while 루프 탈출

        except Exception as e:
                print(f"Error occurred: {e}. Retrying... ({retry_count + 1}/{max_retries})")
                retry_count += 1

    if not success:
            print(">> 요청 실패: 최대 재시도 횟수를 초과했습니다.")

    # print('\n' + ">> researcher: {}".format(response.content))

    # result = convert_text_to_list(plan)
    # print(research)
    # print(plan)

    # 결과 출력
    # for key, value in result.items():
    #     print(f"{key}:")
    #     for item in value:
    #         print(f"  - {item}")
    #     print()
    
    # wrapped_research_area = textwrap.fill(response.research_area, width=80)
    # print('\n' + ">> 전체 response: {}".format(response))
    #print('\n' + ">> 리서치 영역: {}".format(response.research_area))
    #print('\n' + ">> 리서치 방법: {}".format(response.research_direction))

    # wrapped_result = textwrap.fill(response.research_result, width=80)
    # print(">> 리서치 방법: {}".format(wrapped_result))
    # print('\n' + ">> 리서치 결과: {}".format(response.research_result))

    research_direction = response.research_direction
   
    # if archive == None:
    #     archive = []
    #     archive.append(response.research_result)  
    #     # print('n' + ">> ADDED TO archive ")
    
    # else:      
    #     archive.append(response.research_result)  
    # print('\n' + ">> archive: {}".format(archive))

    return {"archive": archive, "question": question, "research_direction": research_direction, "research":response.research_area}
    # return {"plan": response.content, "question": question}


### for researcher
def retrieve(state):
    """
    Retrieve documents

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New key added to state, documents, that contains retrieved documents
    """
    print('\n' + ">> RESEACH")
    # question = state["question"]
    research = state["research"]
    archive = state["archive"]
    research_direction = state["research_direction"]
    retrieve_stop = state["retrieve_stop"]
    retrieve_count = state["retrieve_count"]
    # retrieve_query = state["retrieve_query"]
    question = state["question"]

    if retrieve_stop == None:
        retrieve_stop = "No"
        retrieve_count = 0

    # if retrieve_stop == "No" and retrieve_count > 3:
    if retrieve_stop == "No" and retrieve_count > len(research) - 1:
        retrieve_stop = "Yes"
        documents_content = []
        print('\n' + ">> THE RESEARCH PROCESS IS DONE!")    

    # for r in research:
    #     print(r)
    if retrieve_stop == "No":
        print(">> 요청받은 리서치 영역: {}".format(research[retrieve_count]))    
        print('\n' + ">> retrieve_count: {} | {}".format(retrieve_count, research[retrieve_count]))  

        retry_count = 0
        success = False

        while not success and retry_count < max_retries:
            try:
                # invoke researcher here
                response = researcher.invoke({"research_direction": research_direction, "research": research[retrieve_count], "question": question})
                wrapped_result = textwrap.fill(response.content, width=120)
                print(">> 요청받은 리서치 결과: {}".format(wrapped_result))
                success = True  # 요청 성공 시 while 루프 탈출

            except Exception as e:
                print(f"Error occurred: {e}. Retrying... ({retry_count + 1}/{max_retries})")
                retry_count += 1

        if not success:
            print(">> 요청 실패: 최대 재시도 횟수를 초과했습니다.")
       
        if archive == None:
            archive = []
            if response.content != '':        
                archive.append(response.content)
                print('\n' + ">> Archive START")
                print(">> archive: {}".format(archive))
        else:  
            if response.content != '':        
                archive.append(response.content)
                print('\n' + ">> ADDED TO archive | LENGTH: {}".format(len(archive)))   
                print(">> archive: {}".format(archive))

        # Retrieval
        documents = retriever.get_relevant_documents(research[retrieve_count])

        documents_content = []
        for d in documents:
            documents_content.append(d.page_content)

        # # return {"documents": documents, "question": research}
        retrieve_count = retrieve_count + 1

        # if retrieve_count > 4:
        # if retrieve_count > len(research) - 1:
        #     retrieve_stop = "Yes"
        
    return {"documents": documents_content, "archive":archive, "retrieve_stop": retrieve_stop, "retrieve_count": retrieve_count, "retrieve_query": research[retrieve_count - 1]}


def grade_documents(state):
    """
    Determines whether the retrieved documents are relevant to the question.

    Args:
        state (dict): The current state

    Returns:
        state (dict): Updates documents key with only filtered relevant documents
    """
    global vectorData_use  # Declare vectorData_use as global to modify it
    print('\n' + ">> GRADER  - CHECK DOCUMENT RELEVANCE TO QUESTION")
    question = state["question"]
    retrieve_query = state["retrieve_query"]
    documents = state["documents"]
    archive = state["archive"]

    # doc_txt = documents[1].page_content
    # print('\n' + "---test---")
    # print(">> question: {}".format(question))
    # print(">> score_result: {}".format(retrieval_grader.invoke({"question": question, "documents": doc_txt})))
    # print(">> doc length: {} |  doc: {}".format(len(documents), docs))
    # print(">> doc length: {} | doc[1].page_content: {}".format(len(doc_txt), doc_txt))
    # print("----------" + '\n')

    # scored_result = retrieval_grader.invoke({"question": question, "document": doc_txt})
    # score = scored_result.binary_score

    # Score each doc
    filtered_docs = []
    web_search = "No"
    score = None

    for d in documents:
        #score_result = retrieval_grader.invoke({"retrieve_query": retrieve_query , "documents": d.page_content})
        # score_result = retrieval_grader.invoke({"retrieve_query": retrieve_query , "documents": d})

        try:
            score_result = retrieval_grader.invoke({"retrieve_query": retrieve_query, "documents": d})
            score = score_result.binary_score
        except Exception as e:
            # Handle the error, e.g., log it, or assign a default value to score_result
            print('\n' + ">> Error: {e}")
            score = "No"

        # print(">> score_result: {}".format(score_result))
        #print(">> doc length: {} | doc: {}".format(len(d.page_content), d.page_content))
        print(">> vector document length: {} | vector doc: {}".format(len(d), d))
        
        if score == "yes":
            print(">> GRADE: GOOD 관련있는 문서!")
            filtered_docs.append(d)
            # filtered_docs.append(d.page_content)
            print(filtered_docs)
            web_search = "Yes"
            vectorData_use += 1
            print(">> VECTOR: {}".format(vectorData_use))
        else:
            print(">> GRADE: BAD 관련없는 문서!" + '\n')
            web_search = "Yes"
            continue

    if archive == None:
        archive = []
        print('\n' + ">> archive = []")
        if filtered_docs != []:        
            filtered_docs_ = ' '.join(filtered_docs)
            archive.append(filtered_docs_)
            print('\n' + ">> archive START")
    else:  
        if filtered_docs != []:   
            filtered_docs_ = ' '.join(filtered_docs)     
            archive.append(filtered_docs_)
            print('\n' + ">> ADDED TO archive | LENGTH: {}".format(len(archive)))    

    return {"archive": archive, "question": question, "web_search": web_search}


def report(state):
    print('\n' + ">> CREATE REPORT")

    plan = state["plan"]
    archive = state["archive"]
    question = state["question"]

    print(">> ARCHIVE LENGTH: {} | VECTOR: {}".format(len(archive), vectorData_use))

    success = False
    retry_count = 0

    while not success and retry_count < max_retries:
        try:
            generation = reporter.invoke({"plan":plan, "archive": archive, "question":question}) 
            wrapped_generation = textwrap.fill(generation.content, width=120) 
            # wrapped_generation = textwrap.fill(generation.report, width=120) #for structured output
            print('\n' + ">> REPORT: {}".format(wrapped_generation))
            success = True  # 요청 성공 시 while 루프 탈출

        except Exception as e:
                print(f"Error occurred: {e}. Retrying... ({retry_count + 1}/{max_retries})")
                retry_count += 1

    if not success:
        print(">> 요청 실패: 최대 재시도 횟수를 초과했습니다.")    
   
    return {"generation": generation}


def transform_query(state):
    """
    Transform the query to produce a better question.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): Updates question key with a re-phrased question
    """
    print('\n' + ">> TRANSFORM QUERY")
    question = state["question"]
    documents = state["documents"]
    archive = state["archive"]
    retrieve_query = state["retrieve_query"]

    # Re-write question
    better_query = question_rewriter.invoke({"question": question, "retrieve_query":retrieve_query})
    print(">> 기존 query: {}".format(retrieve_query))
    print(">> 개선된 query: {}".format(better_query))
    return {"documents": documents, "question": better_query, "archive": archive, "retrieve_query":better_query}


def web_search(state):
    """
    Web search based on the re-phrased question.

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): Updates documents key with appended web results
    """
    
    print('\n' + ">> WEB SEARCH ")
    question = state["question"]
    documents = state["documents"]
    archive = state["archive"]
    retrieve_query = state["retrieve_query"]

    ### web search 01
    # docs = web_search_tool.invoke({"query": question})
    # print(docs)
    # web_results = "\n".join([d["content"] for d in docs])

    ## print(web_results)
    ## web_results = Document(page_content=web_results)
    ## documents.append(web_results)

    ### web search 02
    # web_results = tavily_search_tool.search(retrieve_query, search_depth="advanced", include_raw_content=True, max_results=3)["results"]

    try:
        web_results = tavily_search_tool.search(retrieve_query, search_depth="advanced", include_raw_content=True, max_results=4)["results"]
    except HTTPError as e:
        print(f"An HTTP error occurred: {e}")
        web_results = []
    except Exception as e:  # 다른 모든 예외 처리
        print(f"An unexpected error occurred: {e}")
        web_results = []

    results = []
    for i in web_results:
        # result = i['raw_content']
        # result = i['content']
        result = i['raw_content']
        try:
            cleaned_results=cleaner.invoke(({"web_results": result})) 
            print('\n' + ">> CLEANED WEB RESULT: {}".format(cleaned_results.content))
            results.append(cleaned_results.content)

        except Exception as e:    
            if e.code == 400 and 'context_length_exceeded' in e.message:
                print("Context length exceeded error occurred. Skipping this step and continuing.")
        # else:
        #     raise e  # 다른 에러는 다시 발생시킴   
     
        # print('\n' + "{}".format(results))  

    combined_results = " ".join(results)
    print('\n' + ">> COMBINED RESULT: {}".format(combined_results))

    # cleaned_results=cleaner.invoke(({"web_results": combined_results})) 
    # print('\n' + ">> CLEANED WEB RESULT: {}".format(cleaned_results.content))

    # archive.append(cleaned_results.content)
    archive.append(combined_results)

    print('\n' + ">> ADDED TO archive | LENGTH: {} ".format(len(archive)) + '\n')
    # print(">> archive length: {}".format(len(archive)))

    return {"archive":archive, "question": question}


### NOT USING
def generate(state):
    """
    Generate answer

    Args:
        state (dict): The current state

    Returns:
         dict: The updated state with re-phrased question
    """
    print(">> GENERATE ANSWER")
    # messages = state["messages"]
    documents = state["documents"]
    question = state["question"]
    # question = messages[0].content
    # last_message = messages[-1]
    # docs = last_message.content

    # Post-processing
    def format_docs(documents):
        return "\n\n".join(doc.page_content for doc in documents)
    
    # print(">> raw: {}".format(documents))
    print(">> formatted: {}".format(format_docs(documents)))

    # Run
    # generation = rag_chain.invoke({"context": documents, "question": question})
    generation = rag_chain.invoke({"context": format_docs(documents), "question": question})
    print(">> {}".format(generation))
    
    return {"generation": generation}


### NOT USING
def rewrite(state):
    """
    Transform the query to produce a better question.

    Args:
        state (messages): The current state

    Returns:
        dict: The updated state with re-phrased question
    """
    print(">> TRANSFORM QUERY")
    # messages = state["messages"]
    # question = messages[0].content

    question = state["question"]
    documents = state["documents"]

    msg = [
        HumanMessage(content=f""" \n Look at the input and try to reason about the underlying semantic intent / meaning. \n 
        Here is the initial question:
        \n ------- \n
        {question} 
        \n ------- \n
        Formulate an improved question: """,
        )
    ]

    # Grader
    model = ChatOpenAI(temperature=0, model="gpt-4-0125-preview", streaming=True)
    response = model.invoke(msg)
    # return {"messages": [response]}
    return {"question": response}

# print("*" * 20 + "Prompt[rlm/rag-prompt]" + "*" * 20)
# prompt = hub.pull("rlm/rag-prompt").pretty_print()  # Show what the prompt looks like


### Edges
def decide_to_archive(state):
    """
    Determines whether to generate an answer, or re-generate a question.

    Args:
        state (dict): The current graph state

    Returns:
        str: Binary decision for next node to call
    """
    print('\n' + ">> ASSESS GRADED DOCUMENTS")
    state["question"]
    state["documents"]
    web_search = state["web_search"]
    
    if web_search == "Yes":
        # All documents have been filtered check_relevance
        # We will re-generate a new query
        print(">> DECISION: NOT OK - ALL DOCUMENTS ARE NOT RELEVANT TO QUESTION, TRANSFORM QUERY")
        return "transform_query"
    else:
        # We have relevant documents, so generate answer
        print(">> DECISION: OK - ARCHIVED")
        return "researcher"
    

def decide_to_stop(state):   
    print('\n' + "ASSESS WHETHER Retrieve SHOULD STOP")
    retrieve_stop = state["retrieve_stop"]

    if retrieve_stop == "Yes":
        print(">> DECISION: OK - TIME TO STOP")
        return "generate"

    else:
        print("DECISION: CARRY ON THE PROCESS")
        return "researcher"
    

def decide_to_report(state):   
    print('\n' + "ASSESS WHETHER Retrieve SHOULD STOP")
    retrieve_stop = state["retrieve_stop"]

    if retrieve_stop == "Yes":
        print(">> DECISION: OK - TIME TO STOP")
        return "reporter"

    else:
        print("DECISION: CARRY ON THE RESERACH PROCESS")
        return "grader"

### NOT USING        
def decide_to_publish(state):
    """
    Determines whether the generation is grounded in the document and answers question.

    Args:
        state (dict): The current graph state

    Returns:
        str: Decision for next node to call
    """
    print('\n' + ">> CHECK QUALITY")
    question = state["question"]
    documents = state["documents"]
    generation = state["generation"]

    # score = hallucination_grader.invoke(
    #     {"documents": documents, "generation": generation}
    # )
    # grade = score.binary_score

    score = answer_grader.invoke({"question": question, "generation": generation})
    grade = score.binary_score

    # Check question-answering
    if grade == "yes":
        print(">> DECISION: OK TO GO")
        return "useful"
    else:
        print(">> DECISION: NOT OK")
        return "not useful"  
    
print('workflow setting up...')

# Define a new graph
# workflow = StateGraph(AgentState)
# app = workflow.compile()
# app.invoke(inputs, config)

# Define a new graph
# workflow = StateGraph(AgentState)
workflow = StateGraph(GraphState)

# Define the nodes we will cycle between
workflow.add_node("agent", agent)  # agent
workflow.add_node("critic", review) #critic
workflow.add_node("research_director",research) #researcher
workflow.add_node("researcher", retrieve)  # retrieve
workflow.add_node("grader", grade_documents)
workflow.add_node("reporter", report) #final report
workflow.add_node("transform_query", transform_query)  # transform_query
workflow.add_node("web_search_node", web_search)  # web search

workflow.add_edge(START, "agent")
workflow.add_edge("agent", "critic")
workflow.add_edge("critic", "research_director")
workflow.add_edge("research_director", "researcher")

# workflow.add_edge("retrieve", END) #FOR TEST
# workflow.add_edge("retrieve", "grader")

workflow.add_conditional_edges(
    "researcher",
    decide_to_report,
    {
        "grader":"grader",
        "reporter":"reporter"
    },
)

# Decide whether to retrieve
workflow.add_conditional_edges(
    "grader",
    decide_to_archive,
    {
        # Translate the condition outputs to nodes in our graph
        "transform_query": "transform_query",
        "researcher": "researcher",
    },
)

workflow.add_edge("transform_query", "web_search_node")
workflow.add_edge("web_search_node", "researcher")

workflow.add_edge("reporter", END)

#----------------------------------
# # workflow.add_conditional_edges(
# #     "web_search_node",
# #     decide_to_stop,
# #     {
# #         "retrieve":"retrieve",
# #         "generate":"generate"
# #     },
# # )

# workflow.add_edge("web_search_node", "generate")

# workflow.add_conditional_edges(
#     "generate",
#     decide_to_publish,
#     {
#         "useful": END,
#         "not useful": "transform_query",
#     },
# )

# workflow.add_edge("generate", END)
# workflow.add_edge("rewrite", "agent")
#----------------------------------

### setting recursion limit
config = RunnableConfig(recursion_limit=100)
print(config)

# Compile
graph = workflow.compile()

# 컴파일된 그래프 반환
def get_graph():
    return graph

# while True:
#     user_input = input("User: ")
#     if user_input.lower() in ["quit", "exit", "q"]:
#         print('\n' + ">> 도움을 드릴 수 있어 기뻤습니다!")
#         break

#     # inputs = {"question": user_input}  

#     # user_input_ = "Kara Platoni의 '감각의 미래'와 Nanako Nakajima의 'The Aging Body in Dance’,연결지을 수 있는 공통의 맥락을 찾고 contemporary performance artist이 신작 제작을 위해 참고할만한 주제로 발전시켜주세요."
#     user_input_ = "호랑이의 몸짓을 활용하여 contemporary performance를 구성하려고 합니다. 신작 제작을 위한 아이디어를 제시해주세요."
#     inputs = {"question": user_input_}      
#     # for output in graph.stream({"question": ("user", user_input)}):
#     for output in graph.stream(inputs, config):
#         for key, value in output.items():
#             pprint.pprint(f">> Node: [{key}]")
#             pprint.pprint("----------------------------------------------------------------------------------------------------------------")
#             pprint.pprint({"STATE": value}, indent=2, width=150, depth=None)
#     pprint.pprint("----------------------------------------------------------------------------------------------------------------")
#     # Final generation
#     # pprint.pprint(">> GENERATION:")
#     # pprint.pprint(value["generation"], indent=2, width=100, depth=None)
#     # pprint.pprint(">> archive:")
#     # pprint.pprint(value["archive"])
                               
