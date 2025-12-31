module ApplicationHelper
  LOCALE_NAMES = {
    en: "English",
    "zh-CN": "中文"
  }.freeze

  def locale_name(locale)
    LOCALE_NAMES[locale.to_sym] || locale.to_s
  end

  def locale_options_for_select
    I18n.available_locales.map do |locale|
      [ locale_name(locale), url_for(locale: locale == I18n.default_locale ? nil : locale) ]
    end
  end

  def current_locale_url
    url_for(locale: I18n.locale == I18n.default_locale ? nil : I18n.locale)
  end
end
