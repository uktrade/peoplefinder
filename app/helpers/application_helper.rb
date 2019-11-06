# frozen_string_literal: true

module ApplicationHelper
  def home_page_link_helper(path)
    if ENV['HOME_PAGE_URL'].present?
      URI.join(ENV['HOME_PAGE_URL'], path)
    else
      path
    end
  end

  def pluralize_with_delimiter(number, text)
    "#{number_with_delimiter(number)} #{text.pluralize(number)}"
  end

  def last_update
    current_object = @person || @group
    "#{updated_at(@last_updated_at)}#{updated_by(current_object)}." if current_object && @last_updated_at.present?
  end

  def markdown(source)
    options = { header_offset: 2 }
    doc = Kramdown::Document.new(source, options)
    sanitize(doc.to_html, tags: %w[h1 h2 h3 h4 h5 ul li a], attributes: %w[href])
  end

  def markdown_without_hyperlinks(source)
    # In the team description list, we render markdown into an <a> tag,
    # so we don't want any more <a> tags because it would be pointless and
    # be invalid HTML (but we want to preserve the remaining markup).
    original = markdown(source)
    sanitize(original, tags: %w[h1 h2 h3 h4 h5 ul li])
  end

  FLASH_NOTICE_KEYS = %w[error notice warning].freeze

  def flash_messages
    messages = flash.keys.map(&:to_s) & FLASH_NOTICE_KEYS
    return if messages.empty?

    content_tag(:div, class: 'inner-block') do
      content_tag(:div, id: 'flash-messages') do
        messages.inject(ActiveSupport::SafeBuffer.new) do |html, type|
          html << flash_message(type)
        end
      end
    end
  end

  def error_text(key)
    t(key, scope: 'errors')
  end

  def info_text(key)
    t(key, scope: 'views.info_text')
  end

  def app_title
    Rails.configuration.app_title
  end

  def page_title
    (
      [@page_title] << Rails.configuration.app_title
    ).compact.join(' - ')
  end

  def render_search_box?
    logged_in? && !@login_screen && !@editing_mode && !@admin_management
  end

  def call_to(telno)
    return nil unless telno

    digits = telno.gsub(/[^0-9+#*,]+/, '')
    content_tag(:a, href: "tel:#{digits}") { telno }
  end

  def phone_number_with_country_code(country, phone_number)
    if country.present? && phone_number.present?
      "+#{country.country_code} #{phone_number.gsub(/^0/, '')}"
    else
      phone_number
    end
  end

  def call_to_with_country_code(country, phone_number)
    call_to(phone_number_with_country_code(country, phone_number))
  end

  def role_translate(subject, key, options = {})
    if subject == current_user
      subkey = 'mine'
      user = subject
    else
      subkey = 'other'
      user = current_user
    end
    I18n.t([key, subkey].join('.'), options.merge(name: user))
  end

  def bold_tag(term, options = {})
    classes = options[:class] || ''
    options[:class] = classes.split.push('bold-term')
    content_tag(:span, options) { |_tag| term }
  end

  private

  def updated_at(datetime)
    "Last updated: #{l(datetime)}"
  end

  def updated_by(obj)
    " by #{obj.paper_trail_originator}" unless obj.paper_trail_originator == Version.public_user
  end

  def flash_message(type)
    content_tag(:div, class: "flash-message #{type}", role: 'alert') do
      flash[type]
    end
  end
end
