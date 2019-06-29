Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'screenshots#index'
  resource :screenshots do
    member do
      get 'shot'
      get 'testpage'
    end
  end
end
