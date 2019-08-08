Rails.application.routes.draw do
  # EXAMPLE HTML ROUTE
  # get "/photos" => "photos#index"

  # EXAMPLE JSON ROUTE WITH API NAMESPACE
  namespace :api do
  #   get "/photos" => "photos#index"
    get 'directions' => 'schedule#google_maps'
    get 'onebusaway' => 'schedule#onebusaway'
    post 'directions' => 'schedule#create'
    post 'specialdirections' => 'schedule#specialcreate'
  end
end
