# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def mostra_cargo
    html = @resultado['cargo']
    html << " / #{@abrangencia['codigoAbrangencia']}" if @resultado['cargo'] != "Presidente"
    html
  end

  def outros_cargos(atual)
    cargos = [['Presidente', 1], ['Governador', 3], ['Senador', 5], ['Dep. Federal', 6], ['Dep. Estadual', 7]]
    html = %{<ul id="cargos"><li class="select">Selecione um cargo:</li>}
    cargos.each do |cargo|
      html << %{<li>#{link_to(cargo[0], result_url('pi', cargo[1]))}</li>} # unless cargo[0] == atual
    end
    html << "</ul>"
    html
  end
end
