# frozen_string_literal: true

module Pages
  class Management < Base
    set_url '/admin'

    element :audit_trail_link, '#audit-trail > a'
  end
end
