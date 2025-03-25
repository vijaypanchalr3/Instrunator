# dynamic_plot.py
import numpy as np
import matplotlib.pyplot as plt

# Create a figure once
fig, ax = plt.subplots()
mesh = None

def update_plot(data):
    global mesh, ax, fig
    # data should be a 2D numpy array
    if mesh is None:
        # Initial plot
        mesh = ax.pcolormesh(data, shading='auto', cmap='viridis')
        fig.colorbar(mesh, ax=ax)
    else:
        # Update the existing plot:
        mesh.set_array(data[:-1, :-1].ravel())
    plt.draw()
    plt.pause(0.1)
