require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require "sinatra/json"

require 'net/http'
require 'json'

get '/' do
    erb :index
end

post '/add' do
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
    erb :index
    # BGM.create({
    #     music_title: params[:music_title],
    #     itunes_url: 
    # })
end