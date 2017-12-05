# -*- coding: utf-8 -*-
"""
Created on Fri Nov 24 13:46:07 2017

@author: yliu5
"""

import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt('zoo_grid')
fig = plt.figure(figsize=(16,8))

aMax = data[:,0]
rMax = data[:,1]
Training_accuracy = data[:,2]
Validation_accuracy = data[:,3]
zoo = fig.add_subplot(1, 2, 1, projection='3d')
zoo.plot_trisurf(aMax, rMax, Training_accuracy)
zoo.set_xlabel('aMax')
zoo.set_ylabel('rMax')
zoo.set_zlabel('Trainning Accuracy')
zoo = fig.add_subplot(1, 2, 2, projection='3d')
zoo.plot_trisurf(aMax, rMax, Validation_accuracy, cmap=plt.cm.Spectral)
zoo.set_xlabel('aMax')
zoo.set_ylabel('rMax')
zoo.set_zlabel('Validation Accuracy')
plt.show()

data = np.loadtxt('iris_grid')
fig = plt.figure(figsize=(16,8))

aMax = data[:,0]
rMax = data[:,1]
Training_accuracy = data[:,2]
Validation_accuracy = data[:,3]
zoo = fig.add_subplot(1, 2, 1, projection='3d')
zoo.plot_trisurf(aMax, rMax, Training_accuracy)
zoo.set_xlabel('aMax')
zoo.set_ylabel('rMax')
zoo.set_zlabel('Trainning Accuracy')
zoo = fig.add_subplot(1, 2, 2, projection='3d')
zoo.plot_trisurf(aMax, rMax, Validation_accuracy, cmap=plt.cm.Spectral)
zoo.set_xlabel('aMax')
zoo.set_ylabel('rMax')
zoo.set_zlabel('Validation Accuracy')
plt.show()


data = np.loadtxt('german_grid')
fig = plt.figure(figsize=(16,8))

aMax = data[:,0]
rMax = data[:,1]
Training_accuracy = data[:,2]
Validation_accuracy = data[:,3]
zoo = fig.add_subplot(1, 2, 1, projection='3d')
zoo.plot_trisurf(aMax, rMax, Training_accuracy)
zoo.set_xlabel('aMax')
zoo.set_ylabel('rMax')
zoo.set_zlabel('Trainning Accuracy')
zoo = fig.add_subplot(1, 2, 2, projection='3d')
zoo.plot_trisurf(aMax, rMax, Validation_accuracy, cmap=plt.cm.Spectral)
zoo.set_xlabel('aMax')
zoo.set_ylabel('rMax')
zoo.set_zlabel('Validation Accuracy')
plt.show()