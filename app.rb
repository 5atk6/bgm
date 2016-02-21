require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require "sinatra/json"

require 'net/http'
require 'json'
require './models/bgm.rb'

get '/' do
    @bgms = Bgm.all
    erb :index
end

# 対象の曲を選択
post '/select' do
    music_title = params[:music_title]
    artist = params[:artist]
    uri = URI("https://itunes.apple.com/jp/search")
    uri.query = URI.encode_www_form({term: music_title,
        musicArtist: artist, musicTrack: music_title, 
        country: "JP", media: "music", limit: 10})
    res = Net::HTTP.get_response(uri)
    returned_json = JSON.parse(res.body)
    
    #json returned_json
    @musics = returned_json["results"]
    erb :select
end

# データベースに追記
get '/add/:trackId' do
    if Bgm.find_by(track_id: params[:trackId])
        
    else
        Bgm.create({
            track_id: params[:trackId]
        })        
    end
    @bgms = Bgm.all
    erb :index
end    