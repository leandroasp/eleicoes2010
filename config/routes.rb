ActionController::Routing::Routes.draw do |map|
  map.root   :controller => 'resultados'
  map.result ':turno/:estado/:cargo', :controller => 'resultados', :action => 'show' 

  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
