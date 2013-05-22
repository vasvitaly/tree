Tree::Application.routes.draw do

  resources :nodes do 
    collection do
      get 'tree'
    end
    member do
      put 'move'
    end
  end

  root to: 'nodes#tree'

end
