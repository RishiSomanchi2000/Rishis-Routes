class Api::ScheduleController < ApplicationController

#google maps api implementation
  def google_maps
    current_location = "Granite Bay High School".tr(" ", "+")
    destination = "80 Powers Drive".tr(" ", "+")
    @directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{current_location}d&destination=#{destination}&key=#{ENV["API_KEY"]}").parse
    # @directions{'routes'}[1][4][0]{'html_instructions'}
    # @directions{'routes'}{'legs'}{'steps'}[0]{'html_instructions'}
    render 'index.json.jb'
  end

#onebusaway api implementation
  # def onebusaway
  #   @timings = HTTP.get("http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/1_75403.xml?key=").parse
  #   render 'onebusaway.json.jb'
  # end

  def create
    @trip = Trip.new(
      current_location: params[:current_location],
      destination: params[:destination]
      )
    @trip.save
    render 'show.json.jb'
  end

  def specialcreate
    @trip = Trip.new(
      current_location: params[:current_location],
      destination: params[:destination]
      )
    @trip.save

    current_location = @trip.current_location.tr(" ", "+")
    destination = @trip.destination.tr(" ", "+")
    @directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{current_location}d&destination=#{destination}&key=#{ENV["API_KEY"]}").parse
    render 'index.json.jb'
  end
end
