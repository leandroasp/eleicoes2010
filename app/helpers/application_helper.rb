# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def mostra_cargo()
    html = (@cargo == '1'?'Presidente':@cargo == '3'?'Governador':@cargo == '5'?'Senador':@cargo == '6'?'Dep. Federal':@cargo == '7'?'Dep. Estadual':'')
    html << " / #{@abrangencia.upcase}" if @cargo != '1'
    html
  end

  def outros_cargos(estado)
    if (estado == '') 
      estado = 'pi'
    end
	
    cargos = [['Presidente', 'presidente'], ['Governador', 'governador']]
    if (@turno == '1')
      cargos += [['Senador', 'senador'], ['Dep. Federal', 'deputado-federal'], ['Dep. Estadual', 'deputado-estadual']]
    end

    html = %{<ul id="cargos"><li class="select">Selecione um cargo:</li>}
    cargos.each do |cargo|
      html << %{<li>#{link_to(cargo[0], result_url(@turno + 'turno', estado, cargo[1]))}</li>}
    end
    html << "</ul>"
    html
  end

  def show_estados(atual)
    if (@turno == '1')
      estados = ['ac','al','ap','am','ba','ce','df','es','go','ma','mt','ms','mg','pa','pb','pr','pe','pi','rj','rn','rs','ro','rr','sc','sp','se','to'].sort
	else
      estados = ['al','ap','df','go','pa','pb','pi','ro','rr'].sort
	end

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

  def format_number(value, precision = 0)
    number_with_precision value, :unit => '', :separator => ",", :delimiter => ".", :precision => precision
  end
  
  def percent(value)
    format_number(value*100, 1)
  end
end
