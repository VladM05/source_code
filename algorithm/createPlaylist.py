#Load libraries
from time import ctime
from types import NoneType
import numpy as np
import random

happy_adjective = ['content','cheerful','cheery','joyful','joking','gleeful','carefree','untroubled','delighted','smiling','exhilarated','ecstatic','blissful','euphoric','overjoyed']
sad_adjective = ['sad','unhappy','sorrowful','dejected','downcast','down','wretched','gloomy','blue','melancholic','low-spirited','unhappy']
angry_adjective = ['annoyed','irritated','furious','enraged','infuriated','raging','fuming','ranting','outraged','hot-tempered','hostile','antagonistic','mad','wild','livid']
relaxed_adjective = ['relaxed','calm','carefree','casual','composed','easygoing','laid-back','nonchalant','serene','tranquil','collected','chilled','mellowed']
animal_nouns = ['Elephant','Bee','Fox','Giraffe','Lion','Hippo','Fish','Dog','Cat','Tiger','Monkey','Panda']

def createPlaylistName(mood):
    name = ''
    
    random.seed(ctime())
    
    if mood == 'happy':
        name = random.choice(happy_adjective).capitalize() +' '+ random.choice(animal_nouns)
    elif mood == 'sad':
        name = random.choice(sad_adjective).capitalize() +' '+ random.choice(animal_nouns)
    elif mood == 'angry':
        name = random.choice(angry_adjective).capitalize() +' '+ random.choice(animal_nouns)
    elif mood == 'relaxed':
        name = random.choice(relaxed_adjective).capitalize() +' '+ random.choice(animal_nouns)
    
    return name

def getUserAndRecommendedTracks(sp, user):
	results = []
	trackURIs = []

	#total number of tracks to get
	numTracks = 1000
	#max objects allowed for one API call
	maxObjects = 50
	#get numTracks most recent saved tracks from user
	for i in range(numTracks//maxObjects):
		savedTracks = sp.current_user_saved_tracks(limit=maxObjects, 
											  offset=i*maxObjects)
		if (savedTracks != None):
			results.append(savedTracks)

	
	#information about the songs
	for item in results:
		for info in item['items']:
			map_object={'uri':info['track']['uri'],
						'length':info['track']['duration_ms']
            }
			trackURIs.append(map_object)
	
	#pad the list with recommended songs
	for i in range(numTracks//maxObjects):
		recommendedSongs=[]
		tracks=[]
		offset_value=i*5
		for y in range(offset_value,offset_value+5,1):
			tracks.append(trackURIs[y]['uri'])
		recommendedSongs.append(sp.recommendations(seed_tracks=tracks,limit=100))
		for item in recommendedSongs:
			for info in item["tracks"]:
				if(info['uri'] not in trackURIs):
					map_object={'uri':info['uri'],
						'length':info['duration_ms']
            		}
					trackURIs.append(map_object)
	return trackURIs

'''
Takes in list of track URIs and Spotify object
Returns 2D list of form [danceability, energy, valence] for each song
in list
'''
def getAudioFeatures(sp, trackURIs):
	features = []
	featuresTotal = []
	tracks=[]
	for track_obj in trackURIs:
		tracks.append(track_obj['uri'])
	#max number of API calls
	max = 100
	for i in range(0, len(trackURIs), max):
		#get audio features of max tracks at once
		audioFeatures = sp.audio_features(tracks[i:i+max])
		if(audioFeatures!=None and type(audioFeatures)!=NoneType):
			for j in range(len(audioFeatures)):
				if (audioFeatures[j] != None and type(audioFeatures[j])!=NoneType):
					features.append(audioFeatures[j]['danceability'])
					features.append(audioFeatures[j]['energy'])
					features.append(audioFeatures[j]['valence'])
					featuresTotal.append(features)
				features = []
	return featuresTotal

'''
Takes in spotify object, user ID (string), list of user tracks URIs, 2D list of
features of the tracks in the form [[danceability, energy, valence]]
the string mood of the user, and the machine learning model.
Creates playlist for user based on their current mood and model out of 
their tracks. 
'''
def createPlaylist(sp, user, trackURIs, features, mood, model,length):
	featuresArray = np.asarray(features, dtype=np.float32)
	predictions = model.predict(featuresArray)
	songs = []
	playlistSongs = []

	#get all songs that match user's current mood and adds
	#up to 30 of them to playlist
	
	
	for i in range(len(predictions)):
		if (predictions[i] == mood):
			songs.append(trackURIs[i]['uri'])

	random.shuffle(songs)	

	playlistID=''
	if(len(songs)!=0):
		counter=0
		convertToSec=60000
  
		playlistSongs=[]
  
		for i in range(len(songs)):
			playlistSongs.append(songs[i])
			counter=counter+ trackURIs[i]['length']
			if(counter/convertToSec>=length):
				break

		#create new playlist for user
		userID = user['id']
		playlistName = createPlaylistName(mood)
  
		playlist = sp.user_playlist_create(userID,name=playlistName,public=True)
		playlistID = playlist['id']
  
		#add songs to playlist
		print(len(playlistSongs))
		if(len(playlistSongs)>30):
			print('adding more than 30')
			print(int((len(playlistSongs)/30)+1))
			for i in range(0,int((len(playlistSongs)/30)+1),1):
				print('iteration', i)
				offset_value= i*30
				songsToAdd= playlistSongs[offset_value:offset_value+30]
				sp.playlist_add_items(playlistID, songsToAdd)
		else:
			sp.playlist_add_items(playlistID, playlistSongs)

	return playlistID

#main function for file, creates playlist
def main(sp, user, model, mood,length):
	trackURIs= getUserAndRecommendedTracks(sp, user)
	features = getAudioFeatures(sp, trackURIs)
	return createPlaylist(sp, user, trackURIs, features, mood, model,length)