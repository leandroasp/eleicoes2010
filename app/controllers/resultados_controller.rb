require "rubygems"
require "nokogiri"
require "net/http"

class ResultadosController < ApplicationController
  #caches_action :index
  #expire_action :action => :index

  def index
    url = "http://localhost:3000/dados/1turno/pi/pi11.xml"
	url = "http://www.teens180.com/eleicoes2010/1turno/pi/pi11.xml"
    xml = Net::HTTP.get URI.parse(url)
	
    doc = Nokogiri::XML(xml)
	
	@resultado = doc.xpath("//Resultado")[0]
	@abrangencia = doc.xpath("//Abrangencia")[0]
	
	@total_secoes = @abrangencia['secoesTotalizadas'].to_i + @abrangencia['secoesEmRecurso'].to_i + @abrangencia['secoesNaoTotalizadas'].to_i
	@perc_t = 100 * @abrangencia['secoesTotalizadas'].to_i / @total_secoes
	@perc_r = 100 * @abrangencia['secoesEmRecurso'].to_i / @total_secoes
	@perc_n = 100 * @abrangencia['secoesNaoTotalizadas'].to_i / @total_secoes
	
  end

end
