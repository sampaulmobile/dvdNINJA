DvdNINJA::Application.routes.draw do

  get "torrents/index"
  resources :movies, only: [:show, :index]

  root to: "movies#index"

  get '/rt', to: 'movies#index', rt: true, as: :rt
  get '/instant', to: 'movies#instant', as: :instant
  get '/queue', to: 'movies#queue', as: :queue
  get '/update_rt', to: 'movies#update_rt', as: :update_rt
  get '/torrent_rt', to: 'movies#torrent_rt', as: :torrent_rt
  get '/download/*url', to: 'movies#download', as: :download

  get '/torrents', to: 'torrents#index', as: :torrents

end
