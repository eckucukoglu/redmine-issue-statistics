resources :project do
  get '/issuestats', :to => 'issuestats#index', as: 'issuestats'
  post '/issuestats', :to => 'issuestats#show', as: 'issuestats_show'
end
