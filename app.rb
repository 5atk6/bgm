require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require "sinatra/json"

require './models/bookmark.rb'

get '/' do
    erb :index
end