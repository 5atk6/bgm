require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require "sinatra/json"

require 'net/http'
require 'json'
require './models/bgm.rb'

BASE_URL_GOOGLE_MAP = "http://maps.google.com/maps/api/geocode/json"

get '/' do
    @bgms = Bgm.order("count DESC").take(10)
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
    @musics = returned_json["results"]
    
    address = URI.encode(params[:position])
    reqUrl = "#{BASE_URL_GOOGLE_MAP}?address=#{address}&sensor=false&language=ja"
    response = Net::HTTP.get_response(URI.parse(reqUrl))
    data = JSON.parse(response.body)
    xData = data['results'][0]['geometry']['location']['lat']
    yData = data['results'][0]['geometry']['location']['lng']
    Post.create({
        x: xData,
        y: yData
    })
    erb :select
end

# データベースに追記
post '/add' do
    if Bgm.find_by(track_id: params[:trackId])
        Post.last.update({
            bgm_id: Bgm.find_by(track_id: params[:trackId]).id
        })
        Bgm.find_by(track_id: params[:trackId]).update({
            count: Bgm.find_by(track_id: params[:trackId]).count + 1
        })
    else
        Bgm.create({
            artist_id: params[:artistId],
            track_id: params[:trackId],
            artist_name: params[:artistName],
            track_name: params[:trackName],
            count: 1
        })

        Post.last.update({
            bgm_id: Bgm.last.id
        })
    end
    @bgms = Bgm.order("count DESC").take(10)
    erb :index
end

post '/search' do
    targetPrefecture = params[:targetPrefecture]
    @posts = Post.all
    @posts.each do |post|
        xData = post.x
        yData = post.y
        reqUrl = "#{BASE_URL_GOOGLE_MAP}?latlng=#{xData},#{yData}&sensor=false&language=ja"
        response = Net::HTTP.get_response(URI.parse(reqUrl))
        data = JSON.parse(response.body)
        searchResultPrefecture = data['results'][0]['address_components'][6]['long_name']
        if targetPrefecture == searchResultPrefecture then
            
        end
    end
    
    erb :searchResult
end

get '/searchResult' do
    
    erb :searchResult
end

get '/howto' do
    erb :howto
end