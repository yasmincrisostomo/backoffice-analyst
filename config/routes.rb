Rails.application.routes.draw do
  resources :clientes, only: [:index]
end
