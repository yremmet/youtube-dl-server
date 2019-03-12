# frozen_string_literal: true

require "sinatra"
require "securerandom"
require "awesome_print" if ENV["RACK_ENV"] == "development"

$threads = []
$dl=`which youtube-dl`.strip

use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV["HTTP_USERNAME"] && password == ENV["HTTP_PASSWORD"]
end


get "/" do
    @threads=$threads
    @active_idx=@threads.length-1
    erb :root
end

get "/select/:idx" do
    @threads=$threads
    @active_idx=params[:idx].to_i
    erb :root
end

get "/delete/:idx" do
    $threads.delete_at(params[:idx].to_i)
    @threads=$threads
    @active_idx=params[:idx].to_i
    erb :root
end

get '/submit' do
    url=params[:url]
    name=`#{$dl} --get-filename #{url}`

    $threads << Thread.new do # trivial example work thread
        Thread.current["url"]=url
        Thread.current["name"]=name
        puts "#{$dl} -o #{ENV["OUTPUT_DIR"]}/%(title)s-%(id)s.%(ext)s #{url}"
        x=`#{$dl} -o "#{ENV["OUTPUT_DIR"]}/%(title)s-%(id)s.%(ext)s" #{url}`
        Thread.current["logs"] = x
    end
    
    
    @threads=$threads
    @active_idx=$threads.length-1
    erb :root
end

