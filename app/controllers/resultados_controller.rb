require "rubygems"
require "nokogiri"
require "net/http"

class ResultadosController < ApplicationController
  #caches_action :index
  #expire_action :action => :index

  def index
    @estado = params[:estado].to_s
    if (@estado == '')
	  @estado = 'pi'
	end
  end

  def show
    tipo = params[:tipo].to_s
    @estado = tipo == '1'?'br':params[:estado].to_s

  	if (Rails.cache.read("expires" + @estado + tipo) == nil || Time.now > Rails.cache.read("expires" + @estado + tipo))
	    doc = Nokogiri::XML(Net::HTTP.get URI.parse("http://www.teens180.com/eleicoes2010/ler_xml.php?uf=" + @estado + "&cargo=" + tipo + "&file=1"))

  		Rails.cache.write("xml_doc1" + @estado + tipo, doc)
  		Rails.cache.write("expires" + @estado + tipo, Time.now + 90.seconds)
  	else
  		doc = Rails.cache.read("xml_doc1" + @estado + tipo)
  	end

  	@resultado = doc.xpath("//Resultado")[0]
    @abrangencia = doc.xpath("//Abrangencia")[0]
    @voto_candidatos = doc.xpath("//VotoCandidato")
	
	arquivo_fixo = @resultado['nomeArquivoDadosFixos']

    if (Rails.cache.read("xml_doc2" + arquivo_fixo) == nil)
      doc2 = Nokogiri::XML(Net::HTTP.get URI.parse("http://www.teens180.com/eleicoes2010/ler_xml.php?fixo=" + arquivo_fixo))
      Rails.cache.write("xml_doc2" + arquivo_fixo, doc2)
	else
      doc2 = Rails.cache.read("xml_doc2" + arquivo_fixo)
	end
	
	@estado = params[:estado].to_s

    @tipo_cargo = %{Presidente Governador Senador}.include?(@resultado['cargo']) ? "majoritaria" : "proporcional"
    @candidatos = []
    @voto_candidatos.each do |votavel|
      c = {}
      c['totalVotos'] = votavel['totalVotos'].to_i
      c['numero'] = votavel['numeroCandidato'].to_s
      c['percent'] = percents(votavel['totalVotos'].to_f / @abrangencia['votosValidos'].to_i)

      candidato = doc2.css("Candidato[numero='#{votavel['numeroCandidato']}']")[0]
      c['nome'] = candidato['nome'].to_s
      c['nomeUrna'] = candidato['nomeUrna'].to_s
      c['partido'] = doc2.css("Partido[numero='" + votavel['numeroCandidato'][0..1] + "']")[0]['sigla'].to_s
      c['descricaoSituacao'] = candidato['descricaoSituacao'].to_s
      c['situacao'] = (candidato['eleito'].to_s == 'S' ? (c['descricaoSituacao'] == '2º turno' ? 'turno2' : 'eleito') : '')
      @candidatos << c
    end

  	if @abrangencia['eleitoradoNaoApurado'].to_i == 0 && @tipo_cargo == 'proporcional'
  	  eleitos = @candidatos.map { |c| c if c['situacao'] == 'eleito'}.compact.sort_by { |c| c['totalVotos'] }.reverse
  	  nao_eleitos = (@candidatos - eleitos).sort_by { |c| c['totalVotos'] }.reverse
  	  @candidatos = eleitos + nao_eleitos
      # @candidatos = 
       # @candidatos.sort_by { |c| c['totalVotos'] }.reverse
	  else
  	  @candidatos = @candidatos.sort_by { |c| c['totalVotos'] }.reverse
	  end

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
