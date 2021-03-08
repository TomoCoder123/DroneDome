import airsim

class droneAI():
    def __init__(self):
        self.client = airsim.MultirotorClient(ip="127.0.0.1")
        self.client.reset()
        self.client.confirmConnection()
        self.client.enableApiControl(True)
        self.client.armDisarm(True)
        self.client.takeoffAsync()

    def move(self, position):
        #self.client.moveToPositionAsync((7595.873047-6298.0)/100,(12833.351562 - 12991.0)/100,(116.700348+182.0)/-100, 5)
        # self.client.moveToPositionAsync(1073.366699,328.21582,-17.839096, 5)
        # self.client.moveToPositionAsync(1073.366699,328.21582,-17.839096, 5)
        # self.client.moveToPositionAsync(1073.366699,328.21582,-17.839096, 5)

        print("moving")
        self.client.moveOnPathAsync([airsim.Vector3r((7595.873047-6298.0)/100,(12833.351562 - 12991.0)/100,(116.700348+182.0)/-100),
                               airsim.Vector3r((7414.873047-6298.0)/100,(12833.351562 - 12991.0)/100,(3488.700195+182.0)/-100),
                               airsim.Vector3r((20632.875-6298.0)/100,(8874.351562 - 12991.0)/100,(3488.700195+182.0)/-100)], 4)

    def getImage(self, CAMERA_NAME, IMAGE_TYPE):
        return self.client.simGetImage(CAMERA_NAME, IMAGE_TYPE)

    def getState(self):
         return self.client.getMultirotorState()
