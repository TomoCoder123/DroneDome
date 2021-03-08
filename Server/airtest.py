import airsim

client = airsim.MultirotorClient(ip="127.0.0.1")
client.confirmConnection()
client.enableApiControl(True)
client.armDisarm(True)

client.reset()
client.takeoffAsync()

client.moveToPositionAsync(0, 0 , 0, 5)
client.takeoffAsync()

client.moveToPositionAsync(0, 0 , 0, 5)

client.armDisarm(False)

client.enableApiControl(False)

#client.reset()
print("hello")
