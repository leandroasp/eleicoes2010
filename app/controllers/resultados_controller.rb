require "rubygems"
require "nokogiri"
require "net/http"

class ResultadosController < ApplicationController
  #caches_action :index
  #expire_action :action => :index

  def index
  end

  def show
	  estado = params[:estado].to_s
	  tipo = params[:tipo].to_s

  	if (Rails.cache.read("expires" + estado + tipo) == nil || Time.now > Rails.cache.read("expires" + estado + tipo))
	    doc = Nokogiri::XML(Net::HTTP.get URI.parse("http://www.teens180.com/eleicoes2010/ler_xml.php?uf=" + estado + "&cargo=" + tipo + "&file=1"))
	    doc2 = Nokogiri::XML(Net::HTTP.get URI.parse("http://www.teens180.com/eleicoes2010/ler_xml.php?uf=" + estado + "&cargo=" + tipo + "&file=2"))

  		Rails.cache.write("xml_doc1" + estado + tipo, doc)
  		Rails.cache.write("xml_doc2" + estado + tipo, doc2)
  		Rails.cache.write("expires" + estado + tipo, Time.now + 1.minutes)
  	else
  		doc = Rails.cache.read("xml_doc1" + estado + tipo)
  		doc2 = Rails.cache.read("xml_doc2" + estado + tipo)
  	end

  	@resultado = doc.xpath("//Resultado")[0]
	  @abrangencia = doc.xpath("//Abrangencia")[0]
	  @voto_candidatos = doc.xpath("//VotoCandidato")
	
	  @tipo_cargo = %{Presidente Governador Senador}.include?(@resultado['cargo']) ? "majoritaria" : "proporcional"
    @candidatos = []
    @voto_candidatos.each do |votavel|
      c = {}
      c['totalVotos'] = votavel['totalVotos'].to_i
      c['numero'] = votavel['numeroCandidato'].to_s
      c['percent'] = percents(votavel['totalVotos'].to_f / @abrangencia['votosValidos'].to_i)

      candidato = doc2.css("Candidato[numero='#{votavel['numeroCandidato']}']")[0]
      c['nome'] = candidato['nome'].to_s
      c['partido'] = doc2.css("Partido[numero='" + votavel['numeroCandidato'][0..1] + "']")[0]['sigla'].to_s
      c['eleito'] = candidato['eleito'].to_s == 'S'
      c['2turno'] = candidato['descricaoSituacao'].to_s == '2º turno'
      @candidatos << c
    end

  	@candidatos = @candidatos.sort_by { |c| c['totalVotos'] }.reverse

  	@total_secoes = @abrangencia['secoesTotalizadas'].to_i + @abrangencia['secoesEmRecurso'].to_i + @abrangencia['secoesNaoTotalizadas'].to_i
  	@secoes_perc_t = percents(@abrangencia['secoesTotalizadas'].to_f / @total_secoes)
  	@secoes_perc_r = percents(@abrangencia['secoesEmRecurso'].to_f / @total_secoes)
  	@_secoesperc_n = percents(@abrangencia['secoesNaoTotalizadas'].to_f / @total_secoes)
	
  	@total_eleitorado  = @abrangencia['eleitoradoApurado'].to_i + @abrangencia['eleitoradoNaoApurado'].to_i
  	@eleitorado_perc_a = percents(@abrangencia['eleitoradoApurado'].to_f / @total_eleitorado)
  	@eleitorado_perc_n = percents(@abrangencia['eleitoradoNaoApurado'].to_f / @total_eleitorado)
  	@apurado_perc_a = percents(@abrangencia['abstencao'].to_f / @abrangencia['eleitoradoApurado'].to_i)
  	@apurado_perc_c = percents(@abrangencia['comparecimento'].to_f / @abrangencia['eleitoradoApurado'].to_i)
	
  	@votos_perc_b = percents(@abrangencia['votosEmBranco'].to_f / @abrangencia['votosTotalizados'].to_i)
  	@votos_perc_n = percents(@abrangencia['votosNulos'].to_f / @abrangencia['votosTotalizados'].to_i)
  	@votos_perc_p = percents(@abrangencia['votosPendentes'].to_f / @abrangencia['votosTotalizados'].to_i)
  	@votos_perc_v = percents(@abrangencia['votosValidos'].to_f / @abrangencia['votosTotalizados'].to_i)
	
  	@validos_perc_n = percents(@abrangencia['votosNominais'].to_f / @abrangencia['votosValidos'].to_i)
  	@validos_perc_l = percents(@abrangencia['votosLegenda'].to_f / @abrangencia['votosValidos'].to_i)

    @graph_apuracao = Gchart.pie(:size => '275x160', :labels => ['Apurados', 'Não apurados'], :data => [@abrangencia['eleitoradoApurado'].to_i, @abrangencia['eleitoradoNaoApurado'].to_i])
    @graph_votos    = Gchart.pie(:size => '275x160', :labels => ['Abstenção', 'Em branco', 'Nulos', 'Pendentes', 'Válidos'], :data => [@abrangencia['abstencao'].to_i, @abrangencia['votosEmBranco'].to_i, @abrangencia['votosNulos'].to_i, @abrangencia['votosPendentes'].to_i, @abrangencia['votosValidos'].to_i])
  end

  private
    def percents(value, decimal = 1)
      format("%.#{decimal}f", 100 * value)
    end
end
