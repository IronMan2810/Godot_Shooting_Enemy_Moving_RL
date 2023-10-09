import matplotlib.pyplot as plt
import os
import shutil
from constants import ACTIONS

class PlotAgents:
    def __init__(self, agents_num):
        self.agents_rewards = [[0] for _ in range(agents_num)]

    def update_agent(self, agent_n, reward):
        if len(self.agents_rewards[agent_n-1]) > 100:
            del self.agents_rewards[agent_n-1][:1]
        self.agents_rewards[agent_n-1].append(reward)

    def plot(self):
        plt.clf()
        plt.title("Training...")
        plt.xlabel("Number of Games")
        plt.ylabel("Reward")
        for agent_reward in self.agents_rewards:
            plt.plot(agent_reward)
        plt.legend([f"Agent{i}" for i in range(1, len(self.agents_rewards) + 1)], loc='upper left')
        plt.show(block=False)
        plt.pause(1)

def clear_existing_model():
    if os.path.exists("./info_models"):
        shutil.rmtree("./info_models")
    os.makedirs("./info_models")
    
def play_step(idx, socket):
    act = ACTIONS[idx]
    socket.sendall(str.encode(act))
