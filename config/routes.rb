ActionController::Routing::Routes.draw do |map|
  map.root   :controller => 'resultados'
  map.result ':estado', :controller => 'resultados', :action => 'index' 
  map.result ':estado/:tipo', :controller => 'resultados', :action => 'show' 

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
