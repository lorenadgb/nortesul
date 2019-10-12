class CalculadoraController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    @calculadora = Calculadora.new
    @calculadora.rede_eletrica = 'sim'
  end

  def resultado
    @calculadora = Calculadora.new(calculadora_params)

    if @calculadora.valid?
      if calculadora_params[:rede_eletrica] == 'nao'
        @contact = Contact.new(calculadora_params)
        @contact.deliver
        redirect_back(fallback_location: root_path)
      end
    else
      render action: 'new'
    end
  end

  def orcamento
    if request.get?
      @calculadora = Calculadora.new

      @calculadora.local  = params[:local]         if params[:local]
      @calculadora.media  = params[:media]         if params[:media]
      @calculadora.ajuste = params[:ajuste]        if params[:ajuste]
      @calculadora.cidade = params[:cidade]        if params[:cidade]
      @calculadora.estado = params[:estado]        if params[:estado]
    else
      @contact = Contact.new(calculadora_params)
      ContactMailer.contact_message(@contact).deliver! if Rails.env.production?

      @calculadora = Calculadora.new(calculadora_params)

      # generate pdf file
      date     = Time.now.strftime('%d/%m/%Y')
      pdf_name = Time.now.to_i

      pdf_page01 = CombinePDF.load "#{Rails.root}/public/pdf/proposta_comercial_01.pdf"
      pdf_page02 = CombinePDF.load "#{Rails.root}/public/pdf/proposta_comercial_02.pdf"
      pdf_page03 = CombinePDF.load "#{Rails.root}/public/pdf/proposta_comercial_03.pdf"

      # page 01
      pdf_page01.pages[0].textbox date,              height: 20, width: 70, y: 125, x: 490, font_size: 15
      pdf_page01.pages[0].textbox @calculadora.nome, height: 10, width: 70, y: 110, x: 460, font_size: 15

      # page 02
      pdf_page02.pages[0].textbox @calculadora.qtd_paineis.to_s + '',                                                  height: 10, width: 70, y: 570, x: 460, font_size: 12
      pdf_page02.pages[0].textbox @calculadora.kwp.to_d.truncate(1).to_s + ' kWp',                                     height: 10, width: 70, y: 570, x: 340, font_size: 12
      pdf_page02.pages[0].textbox 'R$ ' + ActiveSupport::NumberHelper.number_to_delimited(@calculadora.media).to_s,    height: 10, width: 70, y: 570, x: 220, font_size: 12
      pdf_page02.pages[0].textbox @calculadora.geracao_media.to_s + " kWh/mês",                                        height: 10, width: 70, y: 570, x: 120, font_size: 12

      pdf_page02.pages[0].textbox 'R$ ' + ActiveSupport::NumberHelper.number_to_delimited(@calculadora.economia_25_anos).to_s,    height: 10, width: 70, y: 450, x: 460, font_size: 12
      pdf_page02.pages[0].textbox 'R$ ' + ActiveSupport::NumberHelper.number_to_delimited(@calculadora.economia_anual).to_s,      height: 10, width: 70, y: 450, x: 360, font_size: 12
      pdf_page02.pages[0].textbox @calculadora.retorno.to_d.truncate(1).to_s + ' ANOS',                                           height: 10, width: 70, y: 450, x: 230, font_size: 12
      pdf_page02.pages[0].textbox 'R$ ' + ActiveSupport::NumberHelper.number_to_delimited(@calculadora.investimento_minimo.round(2)).to_s, height: 10, width: 70, y: 450, x: 110, font_size: 12


      pdf = CombinePDF.new
      pdf << pdf_page01
      pdf << pdf_page02
      pdf << pdf_page03

      # pdf.save "#{Rails.root}/public/pdf/output#{pdf_name}.pdf"

      send_data pdf.to_pdf, filename: 'orcamento.pdf', type: 'application/pdf; charset=utf-8', encoding: "UTF-8"
    end
  end

  def download_pdf
    pdf = CombinePDF.load "#{Rails.root}/public/pdf/output#{params[:pdf_name]}.pdf"

    send_data pdf.to_pdf, filename: 'orcamento.pdf', type: 'application/pdf'

    #File.delete("#{Rails.root}/public/pdf/output#{params[:pdf_name]}.pdf")
  end

  private

  def calculadora_params
    params.require(:calculadora).permit(:rede_eletrica, :estado, :cidade, :local, :ajuste, :media, :nome, :email, :telefone)
  end

end
