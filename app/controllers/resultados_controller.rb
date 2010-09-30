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
	@candidatos = doc.xpath("//VotoCandidato")
	
	@total_secoes = @abrangencia['secoesTotalizadas'].to_i + @abrangencia['secoesEmRecurso'].to_i + @abrangencia['secoesNaoTotalizadas'].to_i
	@secoes_perc_t = format("%.2f", 100 * @abrangencia['secoesTotalizadas'].to_f / @total_secoes)
	@secoes_perc_r = format("%.2f", 100 * @abrangencia['secoesEmRecurso'].to_f / @total_secoes)
	@_secoesperc_n = format("%.2f", 100 * @abrangencia['secoesNaoTotalizadas'].to_f / @total_secoes)
	
	@total_eleitorado  = @abrangencia['eleitoradoApurado'].to_i + @abrangencia['eleitoradoNaoApurado'].to_i
	@eleitorado_perc_a = format("%.2f", 100 * @abrangencia['eleitoradoApurado'].to_f / @total_eleitorado)
	@eleitorado_perc_n = format("%.2f", 100 * @abrangencia['eleitoradoNaoApurado'].to_f / @total_eleitorado)
	@apurado_perc_a = format("%.2f", 100 * @abrangencia['abstencao'].to_f / @abrangencia['eleitoradoApurado'].to_i)
	@apurado_perc_c = format("%.2f", 100 * @abrangencia['comparecimento'].to_f / @abrangencia['eleitoradoApurado'].to_i)
	
	@votos_perc_b = format("%.2f", 100 * @abrangencia['votosEmBranco'].to_f / @abrangencia['votosTotalizados'].to_i)
	@votos_perc_n = format("%.2f", 100 * @abrangencia['votosNulos'].to_f / @abrangencia['votosTotalizados'].to_i)
	@votos_perc_p = format("%.2f", 100 * @abrangencia['votosPendentes'].to_f / @abrangencia['votosTotalizados'].to_i)
	@votos_perc_v = format("%.2f", 100 * @abrangencia['votosValidos'].to_f / @abrangencia['votosTotalizados'].to_i)
	
	@validos_perc_n = format("%.2f", 100 * @abrangencia['votosNominais'].to_f / @abrangencia['votosValidos'].to_i)
	@validos_perc_l = format("%.2f", 100 * @abrangencia['votosLegenda'].to_f / @abrangencia['votosValidos'].to_i)
  end

end
