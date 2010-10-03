# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def mostra_cargo
    html = @resultado['cargo']
    html << " / #{@abrangencia['codigoAbrangencia']}" if @resultado['cargo'] != "Presidente"
    html
  end

  def outros_cargos(atual, estado)
    if (estado == '') 
	  estado = 'pi'
	end
    cargos = [['Presidente', 1], ['Governador', 3], ['Senador', 5], ['Dep. Federal', 6], ['Dep. Estadual', 7]]
    html = %{<ul id="cargos"><li class="select">Selecione um cargo:</li>}
    cargos.each do |cargo|
      html << %{<li>#{link_to(cargo[0], result_url(estado, cargo[1]))}</li>} # unless cargo[0] == atual
    end
    html << "</ul>"
    html
  end

  def show_estados(atual)
    estados = ['pi']
    html = %{<select onchange="atualizar(this)"><option value="">UF</option>}
    estados.each do |estado|
	  if atual == estado
        html << %{<option value="#{estado}" selected="selected">#{estado.upcase}</option>}
	  else
        html << %{<option value="#{estado}">#{estado.upcase}</option>}
	  end
    end
    html << "</select>"
    html
  end
end
