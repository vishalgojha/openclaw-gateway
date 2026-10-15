from flask import Flask
app = Flask(__name__)
@app.route('/health')
def health():
    return {"ok":True,"status":"live","service":"personal-agent"}
@app.route('/')
def root():
    return "Personal Agent is running"
if __name__ == '__main__':
    app.run(host='0.0.0.0',port=18789)
