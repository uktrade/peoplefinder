# frozen_string_literal: true

module SpecSupport
  module Login
    def mock_logged_in_user(administrator: false)
      controller.session[ApplicationController::SESSION_KEY] =
        create(:person, ditsso_user_id: '007', role_administrator: administrator).id
    end

    def current_user
      Person.find_by(ditsso_user_id: '007')
    end

    def omni_auth_log_in_as(ditsso_user_id)
      OmniAuth.config.test_mode = true

      OmniAuth.config.mock_auth[:ditsso_internal] = OmniAuth::AuthHash.new(
        provider: 'ditsso_internal',
        uid: ditsso_user_id,
        info: {
          email: 'john.doe@trade.gov.uk',
          user_id: ditsso_user_id,
          first_name: 'John',
          last_name: 'Doe',
          name: 'John Doe'
        }
      )

      visit '/auth/ditsso_internal'
    end

    def omni_auth_log_in_as_administrator
      omni_auth_log_in_as create(:administrator).ditsso_user_id
    end

    def omni_auth_log_in_as_people_editor
      omni_auth_log_in_as create(:people_editor).ditsso_user_id
    end

    def omni_auth_log_in_as_groups_editor
      omni_auth_log_in_as create(:groups_editor).ditsso_user_id
    end
  end
end
