# frozen_string_literal: true

module Pages
  module Sections
    class PersonEmailConfirmForm < SitePrism::Section
      element :email_field, '#person_email'
      element :continue_button, "input[type='submit'][value='Continue'][class='button']"
    end
  end
end
