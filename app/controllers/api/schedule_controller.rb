class Api::ScheduleController < ApplicationController

#google maps api implementation
  def google_maps
    current_location = "Granite Bay High School".tr(" ", "+")
    destination = "80 Powers Drive".tr(" ", "+")
    directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{current_location}d&destination=#{destination}&key=#{ENV["API_KEY"]}").parse
    @total = HTTP.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{current_location}&destinations=#{destination}&key=#{ENV["API_KEY"]}").parse
    # binding.pry
    index = 0
    @steps = []
    while index < directions["routes"][0]["legs"][0]["steps"].count
      @steps << directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"]
      index = index + 1
    end
    @total_time = total['rows'][0]['elements'][0]['duration']['text']
    @total_distance = total['rows'][0]['elements'][0]['distance']['text']
    render 'index.json.jb'
  end

#onebusaway api implementation
  # def onebusaway
  #   @timings = HTTP.get("http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/1_75403.xml?key=").parse
  #   render 'onebusaway.json.jb'
  # end

#simple create for new trip
  def create
    @trip = Trip.new(
      current_location: params[:current_location],
      destination: params[:destination]
      )
    @trip.save
    render 'show.json.jb'
  end
#sends google maps data to front end after user inputs location and destination
  def specialcreate
    @trip = Trip.new(
      current_location: params[:current_location],
      destination: params[:destination]
      )
    @trip.save

    current_location = @trip.current_location.tr(" ", "+")
    destination = @trip.destination.tr(" ", "+")
    directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{current_location}d&destination=#{destination}&key=#{ENV["API_KEY"]}").parse
    total = HTTP.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{current_location}&destinations=#{destination}&key=#{ENV["API_KEY"]}").parse
    index = 0
    count = 1
    @steps = []
    while index < directions["routes"][0]["legs"][0]["steps"].count
      @steps << "#{count}. #{directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"]}"
      index = index + 1
      count = count + 1
    end
    @total_time = total['rows'][0]['elements'][0]['duration']['text']
    @total_distance = total['rows'][0]['elements'][0]['distance']['text']
    render 'index.json.jb'
  end
end
