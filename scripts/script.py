import sys
import json

def process(data):
    # Simulate computation
    result = {
        "status": "success",
        "input": data,
        "message": f"Processed data for {data['name']}"
    }
    return result

if __name__ == "__main__":
    # Read JSON input from stdin
    input_json = sys.stdin.read()
    data = json.loads(input_json)
    print(f"Received data: {data}")

    # Process the input
    output = process(data)

    # Write to output file
    output_file = data.get("output_file", "output.json")
    with open(output_file, "w") as f:
        json.dump(output, f)

    # Optional: print a done message (to signal Node.js)
    print("DONE")
