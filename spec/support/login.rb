# frozen_string_literal: true

module SpecSupport
  module Login
    def mock_logged_in_user(super_admin: false)
      controller.session[::Login::SESSION_KEY] =
        create(:person, ditsso_user_id: '007', super_admin: super_admin).id
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

    def omni_auth_log_in_as_super_admin
      omni_auth_log_in_as create(:super_admin).ditsso_user_id
    end
  end
end
