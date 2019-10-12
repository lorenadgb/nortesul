Rails.application.routes.draw do
  root 'calculadora#new'

  get  'como-funciona', to: 'home#comofunciona'
  get  'a-empresa',     to: 'home#aempresa'
  get  'search',        to: 'home#search'

  resources :contacts,    only: [:new, :create]
  resources :calculadora, only: [:new, :create]

  get  'orcamento', to: 'calculadora#orcamento'
  post 'orcamento', to: 'calculadora#orcamento'

  get  'resultado',    to: 'calculadora#resultado'
  get  'download_pdf', to: 'calculadora#download_pdf'
  post 'resultado',    to: 'calculadora#resultado'

  get 'cities_by_state', to: 'cities#cities_by_state'
  get 'state_by_city',   to: 'states#state_by_city'
  get 'fee_by_state',    to: 'states#fee_by_state'
end
