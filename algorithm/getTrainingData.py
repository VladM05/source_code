#Load libraries
import pandas
import spotipy
from spotipy.oauth2 import SpotifyOAuth
import csv
   
def searchForTracks(sp):
	# Load dataset
	dataset = pandas.read_csv("tagMoods.csv")
	print("search tracks")
	#search spotify for the track, if found record uri and mood
	tracks = []
	tracksForData = []
	for i in range(len(dataset["title"])):
		title = dataset['title'][i]
		print(title)
		#searches for track from dataset in spotify to see if we can get features
		try:
			results = sp.search(q='track:' + title, type='track')
		except:
			continue
		items = results['tracks']['items']
		#search found a track
		if (len(items) > 0):
			#checks if track has same artist as in dataset
			if (items[0]['artists'][0]['name'] == dataset['artist'][i]):
				tracks.append(items[0]['id'])
				tracksForData.append([items[0]['id'], dataset['mood'][i]])
	with open('tracksInSpotify.csv', mode='w',newline='') as file:
		writer = csv.writer(file)
		writer.writerow(['id','mood'])
	    #combine features and data into one line
		for i in range(len(tracksForData)):
			#transform from list to simple string
			line = str(tracksForData[i]).strip('][').replace("'", "").split(', ')
			writer.writerow(line)

def getAudioFeatures(sp):
	#reads tracks found
	dataset = pandas.read_csv("tagMoods.csv")
	#for easy access to track id
	tracks = []
	data = [] 
	for i in range(len(dataset["id"])):
		data.append([dataset["id"][i],dataset["mood"][i]]) 
		tracks.append(dataset["id"][i])

	features = []
	featuresTotal = []
 
	#max number of API calls at once
	max = 100
	for i in range(0, len(dataset["id"]), max):
		#get audio features of max tracks at once
		audioFeatures = sp.audio_features(tracks[i:i+max])
		for j in range(len(audioFeatures)):
			if (audioFeatures != None):
				features.append(audioFeatures[j]['danceability'])
				features.append(audioFeatures[j]['energy'])
				features.append(audioFeatures[j]['valence'])
				featuresTotal.append(features)
			features = []
	return data, featuresTotal

def writeToCSV(data, features):
	#write data to a csv file
	with open('songMoods.csv', mode='w', newline="") as file:
		writer = csv.writer(file)
	    #combine features and data into one line
		for i in range(len(features)):
			line = [data[i][0]] + features[i] + [data[i][1]]
			writer.writerow(line)

scopes = ("user-read-recently-played"
		  " user-top-read"
		  " user-library-modify"
		  " user-library-read"
		  " user-read-private"
		  " playlist-read-private"
		  " playlist-modify-public"
		  " playlist-modify-private"
		  " user-read-email"
		  " user-read-private"
		  " user-read-playback-state"
		  " user-modify-playback-state"
		  " user-read-currently-playing"
		  " app-remote-control"
		  " streaming"
		  " user-follow-read"
		  " user-follow-modify")

def main():
	sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id='86b7c313e0244cd6af549caf74768c91',
                                               client_secret='5723390db8824c258ca23174683ef800',
                                               redirect_uri='https://www.google.com/',
                                               scope=scopes))
	searchForTracks(sp)
	data, features = getAudioFeatures(sp)
	writeToCSV(data, features)

main()