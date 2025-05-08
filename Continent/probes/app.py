from flask import Flask
import time

app = Flask(__name__)
is_healthy = True
is_ready = False  # Simulate slow initialization

@app.route('/health')
def health():
    return {"status": "OK" if is_healthy else "FAIL"}, 200 if is_healthy else 500

@app.route('/ready')
def ready():
    return {"status": "READY" if is_ready else "LOADING"}, 200 if is_ready else 503

@app.route('/status')
def status():
    return {"flight": "BA123", "status": "On Time"}, 200

@app.route('/crash')
def crash():
    global is_healthy
    is_healthy = False  # Simulate crash
    return "Triggered Failure", 500

if __name__ == '__main__':
    # Simulate slow startup (5 sec delay before being ready)
    time.sleep(5)
    is_ready = True
    app.run(host='0.0.0.0', port=8080)
