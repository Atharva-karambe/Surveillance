from flask import Flask, render_template, request, jsonify
from flask_socketio import SocketIO, emit
import pymongo
import joblib
import numpy as np
import datetime


model = joblib.load('model.pkl')
max_rows = 100
max_cols = 50 
target_feature_size = 324

client = pymongo.MongoClient(
  "mongodb://127.0.0.1:27017")
test = client['test']
room = test['rooms']
modle = test['mod']

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'
socketio = SocketIO(app)


@app.route('/')
def index():
  return 'Hello Flask!'


@app.route('/room/<data>')
def inx(data):
  if room.find_one({"roomname": data}):
    current_time = datetime.datetime.now()
    return render_template('map.html',data = data,time = current_time.strftime("%Y-%m-%d") )
  else:
    return "Wrong room code"


@socketio.on('connect')
def on_connect():
  print("Someone is conncted")


@socketio.on('connect_host')
def host_connect(data):
  print(
    room.update_one({"roomname": data["roomcode"]},
                    {"$set": {
                      "hostkey": request.sid
                    }}))


@socketio.on('connect_client')
def client_connect(data):
  try:
    emit("host_key", room.find_one({"roomname": data["roomcode"]})["hostkey"])
  except:
    print("host not found")


@socketio.on('feed')
def feed(data):
  emit('camera_feed', data, room=data["host"])


@socketio.on('marker')
def feed(data):
  emit('marker', data, room=data["host"])
  

@socketio.on('alert')
def feed(data):
  emit('alert', data, room=data["host"])


@socketio.on('data')
def datafeed(data):
  emit('data_feed', data, room=data["host"])
  
@socketio.on('Sencordata')
def datafeed(data):
    acc_matrix = np.array(data['acc'])
    gyo_matrix = np.array(data['gyo'])
    acc_matrix = np.pad(acc_matrix, ((0, max_rows - acc_matrix.shape[0]), (0, max_cols - acc_matrix.shape[1])))
    gyo_matrix = np.pad(gyo_matrix, ((0, max_rows - gyo_matrix.shape[0]), (0, max_cols - gyo_matrix.shape[1])))
    acc_vector = acc_matrix.ravel()
    gyo_vector = gyo_matrix.ravel()
    if len(acc_vector) != target_feature_size // 2 or len(gyo_vector) != target_feature_size // 2:
      return jsonify({'error': f'Input data does not have the correct number of features ({target_feature_size} expected)'})
    input_features = np.concatenate((acc_vector, gyo_vector))
    prediction = model.predict([input_features])[0]
    if(prediction):
       emit('alert', data, room=data["host"])
   
  
@socketio.on('disconnect')
def on_disconnect():
  print("Someone is disconnected")

socketio.run(app, host='0.0.0.0', port="80")
