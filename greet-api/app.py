from flask import Flask, Response, request

CONTENT_TYPE_LATEST = str('text/plain; version=0.0.4; charset=utf-8')

GREETING = os.environ["GREETING"]
app = Flask('greet-api')

@app.route('/', methods=['GET'])
def hello_world():
    return GREETING

if __name__ == '__main__':
    app.run(host = '0.0.0.0', port = 80)