DvdNINJA::Application.routes.draw do

  resources :movies, only: [:show, :index]

  root to: "movies#index"

  get '/rt', to: 'movies#index', rt: true, as: :rt
  get '/instant', to: 'movies#instant', as: :instant


end
