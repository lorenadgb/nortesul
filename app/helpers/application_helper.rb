module ApplicationHelper

  def current_class?(test_path)
    return 'active' if  %r{#{test_path}} =~ request.original_fullpath
  end

  def carousel_item(number, pag)
    number == pag ? 'active' : ''
  end

  def flash_class(level)
    case level
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-error"
    when :alert then "alert alert-error"
    end
  end

  def number_to_currency(value)
    if value == 0 or value.blank?
      raw "&ndash;"
    else
      ActionController::Base.helpers.number_to_currency(value)
    end
  end

  def check_dictionary(icon_text)
    icon_text.include?('checkbox') ? 'NÃO' : 'SIM'
  end

  def local_dictionary(icon_text)
    return 'RESIDENCIAL' if icon_text.include? 'residencial'
    return 'COMERCIAL'   if icon_text.include? 'comercial'
    return 'OUTRO'       if icon_text.include? 'outro'
  end

end
