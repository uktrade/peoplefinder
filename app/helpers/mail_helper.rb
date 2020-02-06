# frozen_string_literal: true

module MailHelper
  APP_GUIDANCE_PAGE = (ENV['HOME_PAGE_URL'] || 'http://test.local').freeze

  def easy_copy_link_to(url:)
    content_tag(:div, style: 'padding: 10px 25px;') do
      link_to url, url, target: '_blank', rel: 'noopener'
    end
  end

  def app_guidance
    content_tag(:p) do
      mailer_t(:app_guidance_html, link: link_to_guidance)
    end
  end

  def do_not_reply
    content_tag(:p, mailer_t(:do_not_reply))
  end

  def link_to_guidance
    link_to('Digital Workspace', APP_GUIDANCE_PAGE, target: '_blank', rel: 'noopener')
  end

  # try relative path then specific scope:
  # e.g. mailer_t(:do_not_reply) in new_profile_email.html.haml
  #  looks up, in order:
  #  - en.user_update_mailer.new_profile_email.do_not_reply
  #  - en.mailers.do_not_reply
  #
  def mailer_t(key, options = {})
    t(
      ".#{key}",
      **options,
      default: t(key, **options, scope: [:mailers])
    )
  end
end
