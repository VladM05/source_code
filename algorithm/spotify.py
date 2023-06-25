#Load libraries
import sys
import json
import spotipy
import spotipy.util as util
from spotipy.oauth2 import SpotifyOAuth
import os
import createPlaylist
import learnSongs

def main(sp,mood,length):
	# scopes = ("user-read-recently-played"
	# 		" user-top-read"
	# 		" user-library-modify"
	# 		" user-library-read"
	# 		" user-read-private"
	# 		" playlist-read-private"
	# 		" playlist-modify-public"
	# 		" playlist-modify-private"
	# 		" user-read-email"
	# 		" user-read-private"
	# 		" user-read-playback-state"
	# 		" user-modify-playback-state"
	# 		" user-read-currently-playing"
	# 		" app-remote-control"
	# 		" streaming"
	# 		" user-follow-read"
	# 		" user-follow-modify")

	# sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id='3a03ffc7f4d8444898577ef4dfe9bc20',
	# 											client_secret='165157f0c8944bd2a534a5544cb8da07',
	# 											redirect_uri='https://www.google.com/',
	# 											scope=scopes))

	#define spotify object and user
	user = sp.current_user()

	#will run till user quits the program
	# while True:
	# 	print("0-Create personalized playlist")
	# 	print("1-exit")
	# 	print("")
	# 	choice = input("Your choice: ")
		#create personalized playlist
		# if choice == '0':
		# 	#user can manually input mood
		# 	print("	Please enter happy, angry, sad, or relaxed")
		# 	choice =  input("Your choice: ")
		# 	if choice != '':
		# 		mood = choice
		
	model = learnSongs.main()
	return createPlaylist.main(sp, user, model, mood,length)