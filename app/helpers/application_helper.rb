# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def mostra_cargo
    html = @resultado['cargo']
    html << " / #{@abrangencia['codigoAbrangencia']}" if @resultado['cargo'] != "Presidente"
    html
  end
end
