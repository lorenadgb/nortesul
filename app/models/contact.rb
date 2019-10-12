class Contact < MailForm::Base
  attribute :nome, :email, :telefone, :estado, :cidade, :mensagem

  def cidade_nome
    city_repository.find(cidade).name if cidade.present?
  end

  def estado_nome
    state_repository.find(estado).name if estado.present?
  end

  private

  def city_repository
    City
  end

  def state_repository
    State
  end
end
