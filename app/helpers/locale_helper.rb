module LocaleHelper
  LOCALE_DATA = {
    en: { code: "EN", name: "English" },
    "zh-CN": { code: "ZH", name: "中文" }
  }.freeze

  def locale_name(locale)
    LOCALE_DATA.dig(locale.to_sym, :name) || locale.to_s
  end

  def locale_code(locale)
    LOCALE_DATA.dig(locale.to_sym, :code) || locale.to_s.upcase[0, 2]
  end

  def locale_url(locale)
    url_for(locale: locale == I18n.default_locale ? nil : locale)
  end

  def current_locale_code
    locale_code(I18n.locale)
  end
end
