require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require "sinatra/json"

require 'net/http'
require 'json'
require './models/bgm.rb'
require 'rexml/document'

BASE_URL_GOOGLE_MAP = "http://maps.google.com/maps/api/geocode/json"
BASE_URL_GEO_API    = "http://geoapi.heartrails.com/api/xml?method=searchByGeoLocation"

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
    xData = data['results'][0]['geometry']['location']['lng']
    yData = data['results'][0]['geometry']['location']['lat']
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
    redirect '/'
end

get '/search' do
    targetPrefecture = params[:targetPrefecture]
    @posts = Post.all
    # @resultPosts = Post.none
    @resultPosts = []
    @resultBgms = Bgm.none
    @hoge = "no"
    @posts.each do |pos|
        xData = pos.x
        yData = pos.y
        # xData = '139.745484'
        # yData = '35.6585696'
        # reqUrl = "#{BASE_URL_GOOGLE_MAP}?latlng=#{xData},#{yData}&sensor=false&language=ja"
        # response = Net::HTTP.get_response(URI.parse(reqUrl))
        # data = JSON.parse(response.body)
        # searchResultPrefecture = data['results'][0]['address_components'][6]['long_name']
        reqUrl = "#{BASE_URL_GEO_API}&amp;x=#{xData}&amp;y=#{yData}"
        doc = REXML::Document.new(open(reqUrl))
        searchResultPrefecture = doc.elements['response/location/prefecture'].text
        if targetPrefecture == searchResultPrefecture
            unless @resultPosts.include?(pos.bgm_id)
                @hoge = pos.bgm_id
                @resultPosts << pos.bgm_id    
            end
            
            
        end
    end
    @resultBgms = Bgm.find(@resultPosts)
    # @resultPosts.each do |resultPost|
    #   @resultBgms << Bgm.find(resultPost.bgm_id) 
    #   if Bgm.find(resultPost.bgm_id)
    #      @hoge = "kkk" 
    #   end
    # end
    erb :searchResult
end

get '/howto' do
    erb :howto
end