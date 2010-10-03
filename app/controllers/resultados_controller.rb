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
	@candidatos = doc.xpath("//VotoCandidato")
	
	@eleitos = Array.new
	@n_eleitos = Array.new
	for i in 1..@candidatos.count do
		@candidatos[i-1]['percent'] = format("%.2f", 100 * @candidatos[i-1]['totalVotos'].to_f / @abrangencia['votosValidos'].to_i)

		candidato = doc2.css("Candidato[numero='" + @candidatos[i-1]['numeroCandidato'] + "']")[0]
		@candidatos[i-1]['nome'] = candidato['nome'].to_s
		@candidatos[i-1]['eleito'] = candidato['eleito'].to_s
		@candidatos[i-1]['partido'] = doc2.css("Partido[numero='" + @candidatos[i-1]['numeroCandidato'][0..1] + "']")[0]['sigla'].to_s
		
		if candidato['eleito'].to_s == 'S'
			@eleitos.push(@candidatos[i-1])
		else
			@n_eleitos.push(@candidatos[i-1])
		end
	end

	@eleitos = @eleitos.sort_by { |i| i['totalVotos'].to_i }.reverse
	@n_eleitos = @n_eleitos.sort_by { |i| i['totalVotos'].to_i }.reverse

	for i in 1..@eleitos.count do
		if (i < 10) 
		  @eleitos[i-1]['seq'] = '000' + i.to_s
		else 
		  @eleitos[i-1]['seq'] = '00' + i.to_s
		end
	end
	for i in 1..@n_eleitos.count do
		j = @eleitos.count + i
		if (j < 10) 
		  @n_eleitos[i-1]['seq'] = '000' + j.to_s
		elsif (j < 100) 
		  @n_eleitos[i-1]['seq'] = '00' + j.to_s
		else 
		  @n_eleitos[i-1]['seq'] = '0' + j.to_s
		end
	end
	
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

    @graph_apuracao = Gchart.pie(:size => '275x160', :labels => ['Apurados', 'Não apurados'], :data => [@abrangencia['eleitoradoApurado'].to_i, @abrangencia['eleitoradoNaoApurado'].to_i])
    @graph_votos    = Gchart.pie(:size => '275x160', :labels => ['Abstenção', 'Em branco', 'Nulos', 'Pendentes', 'Válidos'], :data => [@abrangencia['abstencao'].to_i, @abrangencia['votosEmBranco'].to_i, @abrangencia['votosNulos'].to_i, @abrangencia['votosPendentes'].to_i, @abrangencia['votosValidos'].to_i])
  end

end
