import setup_path
import gym
import airgym
import time
import random
from ray import tune

from stable_baselines3 import DQN
from stable_baselines3.common.envs import SimpleMultiObsEnv
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.common.vec_env import DummyVecEnv, VecFrameStack
from stable_baselines3.common.evaluation import evaluate_policy
from stable_baselines3.common.callbacks import EvalCallback
from stable_baselines3.common.callbacks import CheckpointCallback


# Create a DummyVecEnv for main airsim gym env
env = DummyVecEnv(
    [
        lambda: Monitor(
            gym.make(
                "airgym:airsim-drone-sample-v0",
                ip_address="127.0.0.1",
                step_length=0.5,
                image_shape=(1, 84, 84),
            )
        )
    ]
)

# Wrap env as VecTransposeImage to allow SB to handle frame observations
#env = VecTransposeImage(env)
env._max_episode_steps = 250
channels_order = {"Camera": "first","Pos": None,"Target" : None
                }
env = VecFrameStack(env, n_stack=3, channels_order=channels_order)
# Initialize RL algorithm type and parameters
# model = DQN(
#     "CnnPolicy",
#     env,
#     learning_rate=0.00025,
#     verbose=1,
#     batch_size=64,
#     train_freq=4,
#     target_update_interval=10000,
#     learning_starts=10000,
#     buffer_size=500000,
#     max_grad_norm=10,
#     exploration_fraction=0.1,
#     exploration_final_eps=0.01,
#     device="cuda",
#     tensorboard_log="./tb_logs/",
#
# )
# config = {
#     "env": env,
#     "num_workers": 2,
#     "vf_share_layers": tune.grid_search([True, False]),
#     "lr": tune.grid_search([1e-4, 1e-5, 1e-6]),
#     }
# results = tune.run(
#     'DQN',
#     stop={
#         'timesteps_total': 100000
#     },
#     config=config)
kwargs = dict(
    buffer_size=250,
    policy_kwargs=dict(features_extractor_kwargs=dict(features_dim=32),net_arch=[256, 192, 128]),
)

kwargs["learning_starts"] = 0

model = DQN("MultiInputPolicy", env, gamma=0.5, seed=1, **kwargs,tensorboard_log="./tb_logs/")

# Create an evaluation callback with the same env, called every 10000 iterations
callbacks = []
checkpoint_callback = CheckpointCallback(save_freq=100, save_path='./logs/RL_3.0/',
                                         name_prefix='rld_modelV2.0')
eval_callback = EvalCallback(
    env,
    callback_on_new_best=None,
    n_eval_episodes=5,
    best_model_save_path=".",
    log_path=".",
    eval_freq=1000,
)
callbacks.append(eval_callback)
callbacks.append(checkpoint_callback)

kwargs = {}
kwargs["callback"] = callbacks

# Train for a certain number of timesteps

model.learn(
    total_timesteps=50000,
    tb_log_name="dqn_airsim_drone_run_" + str(time.time()),
    **kwargs
)

# Save policy weights
model.save("dqn_airsim_drone_policy")
