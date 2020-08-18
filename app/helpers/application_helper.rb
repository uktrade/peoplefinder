# frozen_string_literal: true

module ApplicationHelper
  def home_page_link_helper(path = '/')
    if Rails.configuration.home_page_url.present?
      URI.join(Rails.configuration.home_page_url, path).to_s
    else
      path.to_s
    end
  end

  def pluralize_with_delimiter(number, text)
    "#{number_with_delimiter(number)} #{text.pluralize(number)}"
  end

  def markdown(source)
    options = { header_offset: 2 }
    doc = Kramdown::Document.new(source, options)
    sanitize(doc.to_html, tags: %w[h1 h2 h3 h4 h5 p ul ol li a], attributes: %w[href])
  end

  def markdown_without_hyperlinks(source)
    # In the team description list, we render markdown into an <a> tag,
    # so we don't want any more <a> tags because it would be pointless and
    # be invalid HTML (but we want to preserve the remaining markup).
    original = markdown(source)
    sanitize(original, tags: %w[h1 h2 h3 h4 h5 p ul ol li])
  end

  FLASH_NOTICE_KEYS = %w[error notice warning].freeze

  def flash_messages
    messages = flash.keys.map(&:to_s) & FLASH_NOTICE_KEYS
    return if messages.empty?

    tag.div(class: 'inner-block') do
      tag.div(id: 'flash-messages') do
        messages.inject(ActiveSupport::SafeBuffer.new) do |html, type|
          html << flash_message(type)
        end
      end
    end
  end

  def flash_messages_new
    messages = flash.keys.map(&:to_s) & FLASH_NOTICE_KEYS
    return if messages.empty?

    tag.div(id: 'flash-messages') do
      messages.inject(ActiveSupport::SafeBuffer.new) do |html, type|
        html << flash_message_new(type)
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

  def call_to(telno, options = {})
    return nil if telno.blank?

    digits = telno.gsub(/[^0-9+#*,]+/, '')
    tag.a(**options.merge(href: "tel:#{digits}")) { telno }
  end

  def role_translate(subject, key, options = {})
    if subject == current_user
      subkey = 'mine'
      user = subject
    else
      subkey = 'other'
      user = current_user
    end
    I18n.t([key, subkey].join('.'), **options.merge(name: user))
  end

  def bold_tag(term, options = {})
    classes = options[:class] || ''
    options[:class] = classes.split.push('bold-term')
    tag.span(**options) { |_tag| term }
  end

  private

  def flash_message(type)
    tag.div(class: "flash-message #{type}", role: 'alert') do
      flash[type]
    end
  end

  def flash_message_new(type)
    tag.div(class: "ws-flash ws-flash--#{type}", role: 'alert') do
      tag.span(class: 'ws-flash__message') do
        flash[type]
      end
    end
  end
end
