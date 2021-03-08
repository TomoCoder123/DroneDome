from flask import Flask, render_template_string, Response, request, redirect, url_for,jsonify
import json
import airsim
import cv2
from DroneAI import droneAI
import math
import numpy as np
import time

state = {'x': 0.0,'y': 0.0,'xpoint':0.0,'ypoint':0.0}

UPDATE_POS = False
CAMERA_NAME = '0'
IMAGE_TYPE = airsim.ImageType.Scene
DECODE_EXTENSION = '.jpg'
drone = droneAI()

def imgConvert(image):
    np_response_image = np.asarray(bytearray(image), dtype="uint8") #Converts the image to bytearray form.
    decoded_frame = cv2.imdecode(np_response_image, cv2.IMREAD_COLOR)
    ret, encoded_jpeg = cv2.imencode(DECODE_EXTENSION, decoded_frame)
    frame = encoded_jpeg.tobytes()
    return frame

def frame_generator():
#Generates the frames, updates the drones position, and receives input from the app and converts coordinates.
    print("?????")
    while (True):
        drone_state = drone.getState() #Retreives the position of the drone on AirSim
        state['x'], state['y'] = convertCoordsbackwards(drone_state.kinematics_estimated.position.x_val, drone_state.kinematics_estimated.position.y_val)
        response_image = drone.getImage(CAMERA_NAME, IMAGE_TYPE) #Receives image from the camera
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + imgConvert(response_image) + b'\r\n\r\n') #Returns the image back to the webview.

app = Flask(__name__)

def convertCoordsfoward(x, y):
    #Converts the app coordinates to the simulated coordinates
    ux = 1791.977778*(x+90)-39843
    uy = -2015.975*(y-40)-40156
    fx = (ux - 7189)/100
    fy = (uy - 12397)/100
    return fx, fy;

def convertCoordsbackwards(fx, fy):
    #Converts the app coordinates to the simulated coordinateswritten
    ux = (fx*100)+7189
    uy = (fy*100)+12397
    x = (5.580426345*0.0001*(ux+39843))-90
    y = (-4.960378973*0.0001*(uy-40483))
    return x, y;

@app.route('/camerarequest',methods = ['POST'])
def camerarequest():
    global CAMERA_NAME
    global IMAGE_TYPE
    resp = jsonify(success=True)
    if request.form.get('camera')!=None:
        print(request.form.get('camera'))
        CAMERA_NAME = request.form.get('camera')
    else:
        print(request.form.get('mode'))
        if(request.form.get('mode')=='0'):
            IMAGE_TYPE = airsim.ImageType.Scene
            print("default")
        elif(request.form.get('mode')=='1'):
            IMAGE_TYPE = airsim.ImageType.DepthPerspective
            print("depth")
        elif(request.form.get('mode')=='2'):
            print("Infrared")
            IMAGE_TYPE = airsim.ImageType.Infrared
        else:
            resp = jsonify(success=False)

    return resp #Sends confirmation of the getting the message

@app.route('/posrequest',methods = ['POST','GET'])
def requester():
    global UPDATE_POS
    if request.method == 'POST':
        x = float(request.form.get('xpos')) #Gets the coordinates from the post request
        y = float(request.form.get('ypos')) #Gets the coordinates from the post request
        state['xpoint'] , state['ypoint'] = convertCoordsfoward(x,y)
        print(state['y'])
        print(state['x'])
        drone.move(state)
        UPDATE_POS = True  #Sets this to true so frame generator knows to update the drone location
        resp = jsonify(success=True)
        return resp #Sends confirmation of the getting the message
    else:
         return jsonify(x=state['x'], y=state['y'])




@app.route('/')
def index():
    return render_template_string(
        """
            <html>
            <head>
            <style>
                body, html {
                    height: 100%;
                    margin: 0;
                }

                .bg {
                    /* The image used */
                    background-image: url("http://192.168.4.27:5000/video_feed");

                    /* Full height */
                    height: 100%;

                    /* Center and scale the image nicely */
                    background-position: center;
                    background-repeat: no-repeat;
                    background-size: cover;
                }
            </style>
            </head>
            <body>

            <div class="bg"></div>

            </body>
            </html>
        """
        )

#hosts the drones feed
@app.route('/video_feed')
def video_feed():
    return Response(
            frame_generator(),
            mimetype='multipart/x-mixed-replace; boundary=frame'
        )
#starts the server
if __name__ == '__main__':
    app.run(host='192.168.4.27', port=5000, threaded=True)
