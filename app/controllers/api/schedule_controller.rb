class Api::ScheduleController < ApplicationController

  def index
    @directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood&key=#{ENV["API_KEY"]}").parse
    render 'index.json.jb'
  end
end
