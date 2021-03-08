import setup_path
import airsim
import numpy as np
import math
import time
from argparse import ArgumentParser
import random
import gym
from gym import spaces
from gym import Space
from airgym.envs.airsim_env import AirSimEnv
import collections


class AirSimDroneEnv(AirSimEnv):
    def __init__(self, ip_address, step_length, image_shape):
        super().__init__(image_shape)
        self.step_length = step_length
        self.image_shape = image_shape
        self.step_n = 0
        self.state = {
            "position": np.zeros(3),
            "collision": False,
            "prev_position": np.zeros(3),
        }

        self.drone = airsim.MultirotorClient(ip=ip_address)
        self.action_space = spaces.Discrete(7)
        self._setup_flight()

        self.image_request = airsim.ImageRequest(
            3, airsim.ImageType.DepthPerspective, True, False
        )
        global dest
        x = random.uniform((20000 - 7189)/100,(23700 - 7189)/100)
        y = random.uniform((7600 - 12397)/100, (10000 - 12397)/100)
        z = random.uniform((2224 + 449)/-100, (3407 + 449)/-100)
        dest = np.array([x, y, z])

    def __del__(self):
        self.drone.reset()

    #Sets up the drone to take commands
    def _setup_flight(self):
        self.drone.reset()
        self.drone.enableApiControl(True)
        self.drone.armDisarm(True)

        # Set home position and velocity
        self.drone.moveToPositionAsync(0, 0, 0, 10).join()
        #self.drone.moveByVelocityAsync(1, -0.67, -0.8, 5).join()

    #Transforms the image into an AI friendly input
    def transform_obs(self, responses):
        img1d = np.array(responses[0].image_data_float, dtype=np.float)
        if(len(img1d)==0):
            img1d = np.zeros((1,1),dtype=np.float)
        img1d = 255 / np.maximum(np.ones(img1d.size), img1d)
        if(responses[0].height==0 and responses[0].width==0):
            responses[0].height=1
            responses[0].width=1

        img2d = np.reshape(img1d, ( responses[0].height, responses[0].width))

        from PIL import Image

        image = Image.fromarray(img2d)
        im_final = np.array(image.resize((84, 84)).convert("L"))
        im_final = im_final.reshape([84, 84, 1])
        return np.moveaxis(im_final, -1, 0)

    #Gets and returns the image, postion and target of the drone
    def _get_obs(self):
        responses = self.drone.simGetImages([self.image_request])
        image = self.transform_obs(responses)
        self.drone_state = self.drone.getMultirotorState()

        self.state["prev_position"] = self.state["position"]
        self.state["position"] = self.drone_state.kinematics_estimated.position
        print(self.state["position"])
        self.state["velocity"] = self.drone_state.kinematics_estimated.linear_velocity
        collision = self.drone.simGetCollisionInfo().has_collided
        self.state["collision"] = collision

        pos = np.array([self.state["position"].x_val, self.state["position"].y_val,self.state["position"].z_val])
        Vel = np.array([self.state["velocity"].x_val, self.state["velocity"].y_val, self.state["velocity"].z_val])
                #,dtype=np.float32)
        obs = {"Camera":image,"Pos":pos,"Target":dest
                #,"Vel":Vel
                }
        return collections.OrderedDict(obs)

    #Completes the action of moving the AI
    def _do_action(self, action):
        quad_offset = self.interpret_action(action)
        print(quad_offset)
        quad_vel = self.drone.getMultirotorState().kinematics_estimated.linear_velocity
        self.drone.moveByVelocityAsync(
            quad_vel.x_val + quad_offset[0],
            quad_vel.y_val + quad_offset[1],
            quad_vel.z_val + quad_offset[2],
            0.5,
        ).join()

    #Chooses an action based on the output of the AI
    def interpret_action(self, action):
        if action == 0:
            quad_offset = (self.step_length, 0, 0)
        elif action == 1:
            quad_offset = (0, self.step_length, 0)
        elif action == 2:
            quad_offset = (0, 0, self.step_length)
        elif action == 3:
            quad_offset = (-self.step_length, 0, 0)
        elif action == 4:
            quad_offset = (0, -self.step_length, 0)
        elif action == 5:
            quad_offset = (0, 0, -self.step_length)
        else:
            quad_offset = (0, 0, 0)
        return quad_offset

    #Resets the drone to its base position and sets new target
    def reset(self):
        print("RESET---------------------------------")
        self.step_n = 0
        self._setup_flight()
        x = random.uniform((20000 - 7189)/100,(23700 - 7189)/100)
        y = random.uniform((7600 - 12397)/100, (10000 - 12397)/100)
        z = random.uniform((2224 + 449)/-100, (3407 + 449)/-100)
        dest = np.array([x, y, z])
        return self._get_obs()

    #Calculates distance from point to target
    def distanceform(self, point):
        dist = 0
        distArr = dest - point
        for i in distArr:
            dist += i*i
        dist = math.sqrt(dist)
        return dist
    def _compute_reward(self):
        #Gets the postion of the drone
        quad_pt = np.array(list((self.state["position"].x_val, self.state["position"].y_val,self.state["position"].z_val)))
        #Gets the distance of the drone to the target point
        dist = self.distanceform(quad_pt)
        print(self.state["collision"])
        #Checks for collision
        if self.state["collision"]:
            reward = -2
        else:
            reward_dist = (dist)
            #Sets reward in scale with the tanh function
            reward = reward = np.tanh(1 - 0.005*(abs(reward_dist)))
        done = 0
        #if the reward is less than 2 tells the AI its done the episode
        if reward <= -2 or self.step_n >= 400:
            done = 1
        print("reward: "+ str(reward))
        #print("prevdist, distance: "+ str(prevdist)+", " + str(dist))
        return reward,done

    #Calls each of the functions relating to the AI step
    def step(self, action):
        print("step_______________________________________#" + str(self.step_n))
        self.step_n += 1
        self._do_action(action)
        obs = self._get_obs()
        reward, done = self._compute_reward()

        return obs, reward, done, self.state
