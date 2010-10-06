require "rubygems"
require "nokogiri"
require "net/http"

class ResultadosController < ApplicationController
  #caches_action :index
  #expire_action :action => :index

  def index
    #@estado = params[:estado].to_s == ''?'pi':params[:estado].to_s
  end

  def show
	turnos = {"1turno" => 1, "2turno" => 2}
    jobs = {"presidente" => 1, "governador" => 3, "senador" => 5, "deputado-federal" => 6, "deputado-estadual" => 7}

    @turno = turnos[params[:turno]].to_s
    @estado = params[:estado]
    @cargo = jobs[params[:cargo]].to_s
    @abrangencia = (@cargo == '1'?'br':@estado)

    if (Rails.cache.read("expires_#{@abrangencia}#{@turno}#{@cargo}") == nil || Time.now > Rails.cache.read("expires_#{@abrangencia}#{@turno}#{@cargo}"))
      @resultado = JSON.parse(Net::HTTP.get URI.parse("http://divulgacao.tse.gov.br/dados/#{@abrangencia}#{@turno}#{@cargo}.json"))
      Rails.cache.write("resultado_#{@abrangencia}#{@turno}#{@cargo}", @resultado)
      Rails.cache.write("expires_#{@abrangencia}#{@turno}#{@cargo}", Time.now + 90.seconds)
    else
      @resultado = Rails.cache.read("resultado_#{@abrangencia}#{@turno}#{@cargo}")
    end

    @tipo_cargo = %{1 3 5}.include?(@cargo) ? "majoritaria" : "proporcional"
    @candidatos = []
    @resultado['c'].each do |votavel|
      c = {}
      c['totalVotos'] = votavel['v'].to_i
      c['numero'] = votavel['n'].to_s
      c['percent'] = votavel['v'].to_f / @resultado['t'][0]['vv'].to_i
      c['nome'] = votavel['nm'].to_s
      c['partido'] = votavel['cc'].to_s.gsub(/\s-.*$/,'')
      c['descricaoSituacao'] = ''
      c['situacao'] = (votavel['e'].to_s == '*' ? 'eleito' : '')
      @candidatos << c
    end

    @votos_pendente = @resultado['t'][0]['e'].to_i - @resultado['t'][0]['ea'].to_i

    if @votos_pendente == 0 && @tipo_cargo == 'proporcional'
      eleitos = @candidatos.map { |c| c if c['situacao'] == 'eleito'}.compact.sort_by { |c| c['totalVotos'] }.reverse
      nao_eleitos = (@candidatos - eleitos).sort_by { |c| c['totalVotos'] }.reverse
      @candidatos = eleitos + nao_eleitos
    else
      @candidatos = @candidatos.sort_by { |c| c['totalVotos'] }.reverse
    end

    @total_eleitorado  = @resultado['t'][0]['e'].to_i
    @eleitorado_perc_a = @resultado['t'][0]['ea'].to_f / @total_eleitorado
    @eleitorado_perc_n = (@resultado['t'][0]['e'].to_f - @resultado['t'][0]['ea'].to_f) / @total_eleitorado
    @apurado_perc_a = @resultado['t'][0]['a'].to_f / (@resultado['t'][0]['a'].to_i + @resultado['t'][0]['c'].to_i)

    @votos_perc_b = @resultado['t'][0]['vb'].to_f / @resultado['t'][0]['tv'].to_i
    @votos_perc_n = @resultado['t'][0]['vn'].to_f / @resultado['t'][0]['tv'].to_i
    @votos_perc_p = @votos_pendente.to_f / @resultado['t'][0]['tv'].to_f
    @votos_perc_v = @resultado['t'][0]['vv'].to_f / @resultado['t'][0]['tv'].to_i

    @graph_apuracao = Gchart.pie(:size => '275x160', :labels => ['Apurados', 'Não apurados'], :data => [@resultado['t'][0]['ea'].to_i, @resultado['t'][0]['e'].to_i - @resultado['t'][0]['ea'].to_i])
    @graph_votos    = Gchart.pie(:size => '275x160', :labels => ['Em branco', 'Nulos', 'Pendentes', 'Válidos'], :data => [@resultado['t'][0]['vb'].to_i, @resultado['t'][0]['vn'].to_i, @votos_pendente, @resultado['t'][0]['vv'].to_i])
  end

  #private
    #def format_number(value, decimal = 1)
    #  format("%.#{decimal}f", 100 * value)
    #end

end
