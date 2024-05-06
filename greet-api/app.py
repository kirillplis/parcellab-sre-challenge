from flask import Flask, Response, request
import os.path

CONTENT_TYPE_LATEST = str('text/plain; version=0.0.4; charset=utf-8')

GREETING = os.environ["GREETING"]
app = Flask('greet-api')

@app.route('/', methods=['GET'])
def hello_world():
    return f"{GREETING}\n"

if __name__ == '__main__':
    app.run(host = '0.0.0.0', port = 80)