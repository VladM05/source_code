#Load libraries
import pandas
import csv
import sys

#count all the occurences of each tag in the dataset
def getTags():
	# Load dataset
	dataset = pandas.read_csv("muse_v3.csv")
	moods = []
	tags = {}
	for i in range(len(dataset['track'])):
		#csv column list string transformed to a proper list
		moods=dataset['seeds'][i].strip('][').replace("'", "").split(', ')
		for mood in moods:
			if(mood not in tags):
				tags[mood] = 1 
			else:
				tags[mood] = tags[mood] + 1
    
	sortedTags = dict(sorted(tags.items(), key= lambda x:x[1],reverse= True))
	with open('moodTags.csv', mode='w',newline='', encoding='utf-8') as file:
		writer = csv.writer(file)
		writer.writerow(['tags'])
		for tag, value in sortedTags.items():
			writer.writerow([tag,value])
   
def getMood(mood):
    #list for the moods to search for
	searchedMoods=['angry','happy','sad','relaxed']
	
	angryTags=['aggressive','intense','harsh','gritty','brooding']
	happyTags=['cheerful','fun','playful','positive','euphoric']
	sadTags=['gloomy','melancholy','uplifting','cold','negative']
	relaxedTags=['calm','peaceful','smooth','mellow','carefree']
	
	if (mood in searchedMoods):
		return mood
	elif (mood in angryTags):
		return searchedMoods[0]
	elif (mood in happyTags):
		return searchedMoods[1]
	elif (mood in sadTags):
		return searchedMoods[2]
	elif (mood in relaxedTags):
		return searchedMoods[3]

	return None
   
#filters the original dataset
def filterDataset():
    # Load dataset
	dataset = pandas.read_csv("muse_v3.csv", na_filter= False)
	dataset.fillna('')
	tracks = []
	moods = []
	for i in range(len(dataset['track'])):
		#csv column list string transformed to a proper list
		moods=dataset['seeds'][i].strip('][').replace("'", "").split(', ')
		gotMood=False
		for mood in moods:
			resultedMood = getMood(mood)
			if(resultedMood is not None):
				if(len(dataset['track'][i])<100):
					if(dataset['spotify_id'][i] is not ''):
						tracks.append([dataset['track'][i],dataset['artist'][i],dataset['spotify_id'][i],resultedMood])
				gotMood=True
			if(gotMood == True):
				break
	with open('tagMoods.csv', mode='w',newline='', encoding='utf-8') as file:
		writer = csv.writer(file)
		writer.writerow(['title','artist','id','mood'])
		for i in range(len(tracks)):
			line = tracks[i]
			writer.writerow(line)

if(sys.argv[1] == 'tags'):
    getTags()
else:
    filterDataset()