import os
import sys
import spotipy
from spotipy.oauth2 import SpotifyOAuth
from flask import Flask, jsonify, request,session, url_for, session, redirect
from flask_session import Session
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import firestore, credentials

sys.path.append('../algorithm')
import spotify

load_dotenv('config.env')

# initialize Flask app
app = Flask(__name__)
acc_path='spotigen-b2954-firebase-adminsdk-7ui4f-8199b8c6a6.json'
cred = credentials.Certificate(acc_path)
firebase_admin.initialize_app(cred)

# set a random secret key to sign the cookie
app.config['SECRET_KEY'] = os.urandom(64)

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

def update_user(id,auth):
    sp = spotipy.Spotify(auth_manager=auth)
    user=sp.current_user()
    counter=0
    tracks=sp.current_user_saved_tracks(limit=50)['total']
    print(tracks)
    counter=counter+tracks
        
    db = firestore.client()
    doc_users=db.collection('users').document(id)
    doc_users.update({
        'username': user['display_name'],
        'imageUrl': user['images'][0]['url'],
        'likedCounter': counter,
    })

#check if already logged in or not
@app.route('/login')
def first_step():
    
    if 'id' in request.args :
        id = request.args.get('id')
        if(id !='None'):
            cache = spotipy.cache_handler.MemoryCacheHandler()
            db = firestore.client()
            user_token_ref= db.collection('token').document(str(id)).get()
            user_token= user_token_ref.to_dict()
            if(user_token_ref.exists):
                cache.save_token_to_cache(user_token)
                auth_manager = create_spotify_oauth(cache=cache)
                if(auth_manager.is_token_expired(user_token)):
                    token_info = auth_manager.refresh_access_token(user_token['refresh_token'])
                    db.collection('token').document(id).set(token_info)
                update_user(id,auth_manager)
        else:
            auth_url = create_spotify_oauth().get_authorize_url()
            print(auth_url)
            
            return jsonify({
                'logged_in': 'false',
                'redirect_uri': auth_url
            })
    else:
        auth_url = create_spotify_oauth().get_authorize_url()
        print(auth_url)
        
        return jsonify({
            'logged_in': 'false',
            'redirect_uri': auth_url
        })
    
    return jsonify({
            'logged_in': 'true',
    })

# route to handle logging in and the redirect URI after authorization
@app.route('/redirect')
def login():
    
    db = firestore.client()
    auth_manager= create_spotify_oauth()
    auth_manager.get_access_token(request.args.get("code"))

    sp = spotipy.Spotify(auth_manager=auth_manager)
    user=sp.current_user()
    print(user)
    doc_users=db.collection('users').document(user['id'])
    doc_ref = doc_users.get()
    if(doc_ref.exists):
        token_info=auth_manager.get_access_token()
        doc_token=db.collection('token').document(user['id'])
        doc_token.set(token_info)
        
        return jsonify({
                'id': user['id'],
            })
    else:
        counter=0
        tracks=sp.current_user_saved_tracks()['total']
        counter=counter+tracks

        playlistsCreated={
            'total' : 0,
            'happy' : 0,
            'sad' : 0,
            'angry' : 0,
            'relaxed' : 0
        }
        
        doc_users.set({
            'username': user['display_name'],
            'imageUrl': user['images'][0]['url'],
            'likedCounter': counter,
            'playlistsCreated': playlistsCreated
        })
        
        token_info=auth_manager.get_access_token()
        doc_token=db.collection('token').document(user['id'])
        doc_token.set(token_info)
        
        return jsonify({
                'id': user['id'],
            })
    
@app.route('/get_trivial')
def get_trivial_info():
    db = firestore.client()
    id = request.args.get('id')
    user_info_ref= db.collection('users').document(id).get().to_dict()
    
    return jsonify({
        'likes': user_info_ref['likedCounter'],
        'playlists': user_info_ref['playlistsCreated']
    })

@app.route('/get_user_info')
def get_info():
    db = firestore.client()
    id = request.args.get('id')
    print(id)
    cache = spotipy.cache_handler.MemoryCacheHandler()
    user_token_ref= db.collection('token').document(id).get()
    user_token= user_token_ref.to_dict()
    if(user_token_ref.exists):
        cache.save_token_to_cache(user_token)
        auth_manager = create_spotify_oauth(cache=cache)
        if(auth_manager.is_token_expired(user_token)):
            token_info = auth_manager.refresh_access_token(user_token['refresh_token'])
            db.collection('token').document(id).set(token_info)
        update_user(id,auth_manager)
    
    user_info_ref= db.collection('users').document(id).get()
    return jsonify(user_info_ref.to_dict())

@app.route('/get_playlist_info')
def get_playlist_info():
    db = firestore.client()
    id = request.args.get('id')
    playlistID = request.args.get('playlistID')
    print(id)
    cache = spotipy.cache_handler.MemoryCacheHandler()
    user_token_ref= db.collection('token').document(id).get()
    user_token= user_token_ref.to_dict()
    if(user_token_ref.exists):
        cache.save_token_to_cache(user_token)
        auth_manager = create_spotify_oauth(cache=cache)
        if(auth_manager.is_token_expired(user_token)):
            token_info = auth_manager.refresh_access_token(user_token['refresh_token'])
            db.collection('token').document(id).set(token_info)
    
    auth_manager = create_spotify_oauth(cache=cache)
    
    sp = spotipy.Spotify(auth_manager=auth_manager)
    
    print(playlistID)
    playlistID = 'spotify:playlist:'+playlistID
    playlist = sp.playlist(playlistID)
    
    total_duration = 0
    
    for item in playlist['tracks']['items']:
        total_duration = total_duration + item['track']['duration_ms']
    
    playlist['total_duration'] = total_duration
    
    print(playlist)
    return jsonify(playlist)

@app.route('/generate')
def generate_playlist():
    
    cache = spotipy.cache_handler.MemoryCacheHandler()
    db = firestore.client()
    id = request.args.get('id')
    print(id)
    if(id !='None'):
        user_token_ref= db.collection('token').document(id).get()
        user_token= user_token_ref.to_dict()
        if(user_token_ref.exists):
            cache.save_token_to_cache(user_token)
            auth_manager = create_spotify_oauth(cache=cache)
            if(auth_manager.is_token_expired(user_token)):
                token_info = auth_manager.refresh_access_token(user_token['refresh_token'])
                db.collection('token').document(id).set(token_info)

    auth_manager = create_spotify_oauth(cache=cache)
    
    sp = spotipy.Spotify(auth_manager=auth_manager)
    
    oldPlaylistID = request.args.get('oldID', default= None)    
    if(oldPlaylistID != None):
        sp.user_playlist_unfollow(id,oldPlaylistID)
    
    mood = str(request.args.get('mood',default='happy')).lower()
    if(mood == 'mood'):
        mood = 'happy'
        
    length = int(request.args.get('length', default= 30))
    if(length == 0):
        length = 30
        
    print(id,':',mood,' and',length)
    
    playlistID=spotify.main(sp,mood,length)
    
    if(oldPlaylistID == None):
        doc_user=db.collection('users').document(id)
        old_doc=doc_user.get().to_dict()
        
        lengthField = str(length)+' min'
        doc_user.update({
            'playlistsCreated.total': old_doc['playlistsCreated']['total']+1,
            'playlistsCreated.moods.'+mood : old_doc['playlistsCreated']['moods'][mood]+1,
            'playlistsCreated.lengths.'+lengthField : old_doc['playlistsCreated']['lengths'][lengthField]+1
        })

    # return a success message
    return jsonify({
        'playlistID': playlistID
    })

def create_spotify_oauth(show_dialog = True , cache = None):
    
    if(cache == None):
        cache = spotipy.cache_handler.MemoryCacheHandler()
    oauth= SpotifyOAuth(
        client_id = os.getenv('SPOTIPY_CLIENT_ID'),
        client_secret = os.getenv('SPOTIPY_CLIENT_SECRET'),
        redirect_uri = url_for('login', _external=True),
        scope=scopes,
        cache_handler= cache,
        show_dialog=show_dialog
    )
    return oauth

app.run(host='0.0.0.0',debug=True)