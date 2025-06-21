import sys
import json
import asyncio
from dotenv import load_dotenv
load_dotenv()
from langchain_openai import ChatOpenAI
from browser_use.agent.views import AgentHistoryList
from browser_use import Agent


llm = ChatOpenAI(model="gpt-4o-mini")

def process(data):
    # Simulate computation
    result = {
        "status": "success",
        "input": data,
        "message": f"Processed data for {data['name']}"
    }
    return result

async def main(task):
    agent = Agent(
        task=task,
        llm=llm,
    )
    history: AgentHistoryList = await agent.run()
    result = history.final_result()
    return result

def run_agent_task():
    # Read JSON input from stdin
    input_json = sys.stdin.read()
    data = json.loads(input_json)
    print(f"Received data: {data}")

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)

    # Process the input
    output = loop.run_until_complete(main(data['task']))
    # output = process(data)

    # Write to output file
    output_file = data.get("output_file", "output.txt")
    with open(output_file, "w") as f:
        f.write(output)

    # Optional: print a done message (to signal Node.js)
    print("DONE")


if __name__ == "__main__":
    run_agent_task()




# from langchain_openai import ChatOpenAI
# from browser_use import Agent
# from dotenv import load_dotenv
# load_dotenv()

# import asyncio

# llm = ChatOpenAI(model="gpt-4o-mini")

# async def main():
#     agent = Agent(
#         task="Find the developer's website for the clearme idv service. From the developer's website find all the api urls and their descriptions.",
#         llm=llm,
#     )
#     result = await agent.run()
#     print(result)

# asyncio.run(main())

# async def run_agent_task(task: str):
#     agent = Agent(
#         task=task,
#         llm=llm,
#     )
#     result = await agent.run()
#     return result