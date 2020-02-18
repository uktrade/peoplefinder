# frozen_string_literal: true

module Pages
  class Management < Base
    set_url '/admin'

    element :reports_tab, '#reports'
    element :tools_tab, '#tools'
    element :metrics_tab, '#metrics'
  end
end
