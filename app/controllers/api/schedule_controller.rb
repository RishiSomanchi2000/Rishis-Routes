class Api::ScheduleController < ApplicationController

#google maps api implementation
  def google_maps
    current_location = "80 Powers Drive".tr(" ", "+")
    destination = "Thai Paradise Folsom".tr(" ", "+")
    directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{current_location}d&destination=#{destination}&key=#{ENV["GOOGLE_KEY"]}").parse
    total = HTTP.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{current_location}&destinations=#{destination}&key=#{ENV["GOOGLE_KEY"]}").parse
    # binding.pry

    index = 0
    @steps = []
    while index < directions["routes"][0]["legs"][0]["steps"].count
      @steps << directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"]
      index = index + 1
    end


    @destination_lat = directions['routes'][0]['legs'][0]['end_location']['lat']
    @destination_long = directions['routes'][0]['legs'][0]['end_location']['lng']
    @total_time = total['rows'][0]['elements'][0]['duration']['text']
    @total_distance = total['rows'][0]['elements'][0]['distance']['text']

    @yelp = HTTP.get("https://api.yelp.com/v3/businesses/search?term=food&latitude=#{@destination_lat}&longitude=#{@destination_long}&", headers: {"Authorization": "Bearer #{ENV['YELP_KEY']}"}).parse
    @weather = HTTP.get("http://api.openweathermap.org/data/2.5/weather?lat=#{@destination_lat}&lon=#{@destination_long}&appid=#{ENV['WEATHER_KEY']}").parse
    @description = @weather['weather'][0]['main']
    @temp = sprintf("%.2f", (((((@weather['main']['temp']) - 273.15) * 9)/5) + 32))
    @humidity = @weather['main']['humidity']
    @windspeed = @weather['wind']['speed']

    index2 = 0
    @names = []
    @images = []
    @rating = []
    @phone = []
    while index2 < @yelp['businesses'].count
      @names << @yelp['businesses'][index2]['name']
      @images << @yelp['businesses'][index2]['image_url']
      @rating << @yelp['businesses'][index2]['rating']
      @phone << @yelp['businesses'][index2]['display_phone']
      index2 = index2 + 1
    end

    render 'index.json.jb'
  end

#onebusaway api implementation
  # def onebusaway
  #   @timings = HTTP.get("http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/1_75403.xml?key=").parse
  #   render 'onebusaway.json.jb'
  # end

#Yelp api implementation
  def yelp
    @trip = Trip.new(
      current_location: params[:current_location],
      destination: params[:destination]
      )
    @trip.save
    current_location = @trip.current_location.tr(" ", "+")
    destination = @trip.destination.tr(" ", "+")
    directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{current_location}d&destination=#{destination}&key=#{ENV["GOOGLE_KEY"]}").parse
    @destination_lat = directions['routes'][0]['legs'][0]['end_location']['lat']
    @destination_long = directions['routes'][0]['legs'][0]['end_location']['lng']
    @yelp = HTTP.get("https://api.yelp.com/v3/businesses/search?term=delis&latitude=#{@destination_lat}&longitude=-121.0881135&", headers: {"Authorization": "Bearer #{ENV['YELP_KEY']}"}).parse
    index2 = 0
    @names = []
    @images = []
    @rating = []
    @phone = []
    @address = []
    while index2 < @yelp['businesses'].count
      word = ""
      @names << @yelp['businesses'][index2]['name']
      @images << @yelp['businesses'][index2]['image_url']
      @rating << @yelp['businesses'][index2]['rating']
      @phone << @yelp['businesses'][index2]['display_phone']
      @address << "#{@yelp['businesses'][index2]['location']['address1']}, #{@yelp['businesses'][index2]['location']['city']}"
      index2 = index2 + 1
    end
    render 'yelp.json.jb'
  end

  #weather api implementation
  def weather
    @trip = Trip.new(
      current_location: params[:current_location],
      destination: params[:destination]
      )
    @trip.save
    current_location = @trip.current_location.tr(" ", "+")
    destination = @trip.destination.tr(" ", "+")
    directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{current_location}d&destination=#{destination}&key=#{ENV["GOOGLE_KEY"]}").parse
    @destination_lat = directions['routes'][0]['legs'][0]['end_location']['lat']
    @destination_long = directions['routes'][0]['legs'][0]['end_location']['lng']
    @weather = HTTP.get("http://api.openweathermap.org/data/2.5/weather?lat=#{@destination_lat}&lon=#{@destination_long}&appid=#{ENV['WEATHER_KEY']}").parse
    @description = @weather['weather'][0]['main']
    @temp = sprintf("%.2f", (((((@weather['main']['temp']) - 273.15) * 9)/5) + 32))
    @humidity = @weather['main']['humidity']
    @windspeed = @weather['wind']['speed']
    render 'weather.json.jb'
  end


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
    directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{current_location}d&destination=#{destination}&key=#{ENV["GOOGLE_KEY"]}").parse
    total = HTTP.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{current_location}&destinations=#{destination}&key=#{ENV["GOOGLE_KEY"]}").parse
    # binding.pry
    
    index = 0
    count = 1
    @steps = []
    while index < directions["routes"][0]["legs"][0]["steps"].count
      if directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"].include?("Destination")
        start = directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"].index("Destination")
        temp_last = directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"].remove("<b>", "</b>", "<div style=\"font-size:0.9em\">", "</div>", "Restricted usage road")
        last = temp_last.length - 1
        @final_direction = directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"][start, last]
      end
      @steps << "#{count}. #{directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"]}".remove("<b>", "</b>", "<div style=\"font-size:0.9em\">", "</div>", "Restricted usage road", "Destination will be on the right", "Destination will be on the left")
      index = index + 1
      count = count + 1
    end
    @steps << "#{count}. #{@final_direction}".remove("<b>", "</b>", "<div style=\"font-size:0.9em\">", "</div>", "Restricted usage road")

    @destination_lat = directions['routes'][0]['legs'][0]['end_location']['lat']
    @destination_long = directions['routes'][0]['legs'][0]['end_location']['lng']
    @total_time = total['rows'][0]['elements'][0]['duration']['text']
    @total_distance = total['rows'][0]['elements'][0]['distance']['text']

    @yelp = HTTP.get("https://api.yelp.com/v3/businesses/search?term=food&latitude=#{@destination_lat}&longitude=#{@destination_long}&", headers: {"Authorization": "Bearer #{ENV['YELP_KEY']}"}).parse
    @weather = HTTP.get("http://api.openweathermap.org/data/2.5/weather?lat=#{@destination_lat}&lon=#{@destination_long}&appid=#{ENV['WEATHER_KEY']}").parse
    @description = @weather['weather'][0]['main']
    @temp = sprintf("%.2f", (((((@weather['main']['temp']) - 273.15) * 9)/5) + 32))
    @humidity = @weather['main']['humidity']
    @windspeed = @weather['wind']['speed']

    index2 = 0
    @names = []
    @images = []
    @rating = []
    @phone = []
    while index2 < @yelp['businesses'].count
      @names << @yelp['businesses'][index2]['name']
      @images << @yelp['businesses'][index2]['image_url']
      @rating << @yelp['businesses'][index2]['rating']
      @phone << @yelp['businesses'][index2]['display_phone']
      index2 = index2 + 1
    end

    render 'index.json.jb'
  end

  def googlemaps
    @trip = Trip.new(
      current_location: params[:current_location],
      destination: params[:destination]
      )
    @trip.save

    current_location = @trip.current_location.tr(" ", "+")
    destination = @trip.destination.tr(" ", "+")
    directions = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{current_location}d&destination=#{destination}&key=#{ENV["GOOGLE_KEY"]}").parse
    total = HTTP.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{current_location}&destinations=#{destination}&key=#{ENV["GOOGLE_KEY"]}").parse
    @total_time = "Time: #{total['rows'][0]['elements'][0]['duration']['text']} |"
    @total_distance = "Distance: #{total['rows'][0]['elements'][0]['distance']['text']}"
    index = 0
    count = 1
    @steps = []
    @distance = []
    @duration = []
    while index < directions["routes"][0]["legs"][0]["steps"].count
      # if directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"].include?("Destination")
      #   start = directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"].index("Destination")
      #   temp_last = directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"].remove("<b>", "</b>", "<div style=\"font-size:0.9em\">", "</div>", "Restricted usage road")
      #   last = temp_last.length - 1
      #   @final_direction = directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"][start, last]
      # end
      @steps << "#{count}. #{directions["routes"][0]["legs"][0]["steps"][index]["html_instructions"]}".remove("<b>", "</b>", "<div style=\"font-size:0.9em\">", "</div>", "Restricted usage road", "Destination will be on the right", "Destination will be on the left", "/<wbr/>")
      @distance << directions['routes'][0]['legs'][0]['steps'][index]['distance']['text']
      @duration << directions['routes'][0]['legs'][0]['steps'][index]['duration']['text']
      index = index + 1
      count = count + 1
    end
    # @steps << "#{count}. #{@final_direction}".remove("<b>", "</b>", "<div style=\"font-size:0.9em\">", "</div>", "Restricted usage road")
    render 'googlemaps.json.jb'

    
  end


end
