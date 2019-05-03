# frozen_string_literal: true

module Pages
  module Sections
    class Audit < SitePrism::Section
      elements :versions, 'tbody tr'
    end
  end
end
