class Calculadora
  include ActiveModel::Model

  attr_accessor :rede_eletrica, :estado, :cidade, :local, :ajuste, :media
  attr_accessor :nome, :telefone, :email
  attr_accessor :pdf_name

  validates_presence_of :rede_eletrica, :estado, :cidade, :local, :ajuste, :media, if: :acesso_a_rede_eletrica?
  validates_presence_of :rede_eletrica, :nome, :telefone, :email, unless: :acesso_a_rede_eletrica?

  HUMANIZED_ATTRIBUTES = {
      local:  'Tipo do local da instalação',
      ajuste: 'Ajuste da tarifa',
      media:  'Energia por mês'
  }

  MEDIA_DIAS_POR_MES   = 30
  MEDIA_HORAS_BRASIL   = 4
  MEDIA_MINIMA         = 4500
  MEDIA_MAXIMA         = 5500
  NUMERO_MESES_ANO     = 12
  NUMERO_MESES_25_ANOS = NUMERO_MESES_ANO * 25
  POTENCIA_MEDIA_PLACA = 330

  def self.human_attribute_name(attr, options = {}) # 'options' wasn't available in Rails 3, and prior versions.
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def kwp
    kw = media.to_f / ajuste_ou_default.to_f

    (kw / MEDIA_DIAS_POR_MES) / MEDIA_HORAS_BRASIL
  end

  def ajuste_ou_default
    ajuste.nil? ? get_taxa_sem_ajuste : ajuste
  end

  def investimento_minimo
    kwp * MEDIA_MINIMA
  end

  def investimento_maximo
    kwp * MEDIA_MAXIMA
  end

  def economia_mensal
    media.to_f
  end

  def economia_anual
    economia_mensal * NUMERO_MESES_ANO
  end

  def economia_25_anos
    economia_mensal * NUMERO_MESES_25_ANOS
  end

  def retorno
    (investimento_minimo / economia_mensal) / NUMERO_MESES_ANO
  end

  def cidade_nome
    city_repository.find(cidade).name
  end

  def qtd_paineis
    (kwp / POTENCIA_MEDIA_PLACA * 100).to_i
  end

  def geracao_media
    (economia_mensal / ajuste_ou_default.to_f).to_i
  end

  private

  def acesso_a_rede_eletrica?
    rede_eletrica == 'sim'
  end

  def get_taxa_sem_ajuste
    state = state_repository.find(estado)

    case local
    when 'residencial'
      state.residencial
    when 'comercial'
      state.comercial
    when 'outro'
      state.outro
    end

  end

  def city_repository
    City
  end

  def state_repository
    State
  end
end
