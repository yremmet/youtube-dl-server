# frozen_string_literal: true

require "sinatra"
require "securerandom"
require "awesome_print" if ENV["RACK_ENV"] == "development"

$threads = []
$dl=`which youtube-dl`.strip

if ENV["AUTH"] == "basic" then 
    use Rack::Auth::Basic, "Protected Area" do |username, password|
        username == ENV["HTTP_USERNAME"] && password == ENV["HTTP_PASSWORD"]
    end
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
    sound=params[:sound] || "false"
    name=`#{$dl} --get-filename #{url}`

    $threads << Thread.new do # trivial example work thread
        Thread.current["url"]=url
        Thread.current["name"]=name
        if url.include? "tiktok" then
            command="#{$dl} -o \"#{ENV["OUTPUT_DIR"]}/%(title)s-%(id)s.mp4\" #{url}"
        else     
            if sound == "false" then
                command="#{$dl} -f 'bestvideo[ext=mp4]' -o \"#{ENV["OUTPUT_DIR"]}/%(title)s-%(id)s.%(ext)s\" #{url}"
            else
                command="#{$dl} --extract-audio --audio-format aac -o \"#{ENV["OUTPUT_DIR"]}/%(title)s-%(id)s.%(ext)s\" #{url}"
            end
        end
        puts "#{command}"
        x=`#{command}`
        Thread.current["logs"] = x
    end
    
    
    @threads=$threads
    @active_idx=$threads.length-1
    erb :root
end

