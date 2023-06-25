# Load libraries
import random
import numpy as np
import pandas
from pandas.plotting import scatter_matrix
from sklearn import model_selection, tree
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.ensemble import AdaBoostClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
import os

def splitDataset(dataset, seed):
	array = dataset.values
	X = array[:,1:4]
	Y = array[:,4]
	validation_size = 0.2
	X_train, X_validation, Y_train, Y_validation = model_selection.train_test_split(X, Y,
												   test_size=validation_size,
												   random_state=seed)
 
	return X_train, X_validation, Y_train, Y_validation


def tryClassifiers(X_train, Y_train, seed, scoring):
	models = []
	models.append(('Linear Discriminant Analysis', LinearDiscriminantAnalysis()))
	models.append(('K Neighbors', KNeighborsClassifier()))
	models.append(('Decision Tree', DecisionTreeClassifier()))
	models.append(('AdaBoost', AdaBoostClassifier()))
	models.append(('Logistic Regression', LogisticRegression()))
	models.append(('Support Vector Machine', SVC()))
	models.append(('Gaussian Naive Bayes', GaussianNB()))

	#Try each model and print out the results of each one
	results = []
	names = []
	for name, model in models:
		kfold = model_selection.KFold(n_splits=7, shuffle=True, random_state=seed)
		cv_results = model_selection.cross_val_score(model, X_train, Y_train, cv=kfold, scoring=scoring)
		results.append(cv_results)
		names.append(name)
		mean = cv_results.mean()
		stdDev = cv_results.std()
		msg = "%s: %f (%f)" % (name, mean, stdDev)
		print(msg)

def checkModel(model, X_train, Y_train, X_validation, Y_validation):
	model.fit(X_train, Y_train)
	#predictions = model.predict(X_validation)
	# print(accuracy_score(Y_validation, predictions))
	return model

def main():
	# Load dataset
	print(os.getcwd())
	if(os.getcwd().find('algorithm')!= -1):
		dataset = pandas.read_csv("songMoods.csv",
								names=['id','danceability', 'energy', 
										'valence', 'mood'])
	else:
		dataset = pandas.read_csv("../algorithm/songMoods.csv",
								names=['id','danceability', 'energy', 
										'valence', 'mood'])
	seed = 35
	#scoring = 'accuracy'
	#split dataset into training and validation data
	X_train, X_validation, Y_train, Y_validation = splitDataset(dataset, seed)
	#try multiple classifiers and print data on how well they perform
	#tryClassifiers(X_train, Y_train, seed, scoring)
	#chose model based on results
	chosenModel =  SVC()
	model = checkModel(chosenModel, X_train, Y_train,
					   X_validation, Y_validation)
	return model