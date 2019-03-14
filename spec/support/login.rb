module SpecSupport
  module Login
    def mock_logged_in_user super_admin: false
      controller.session[::Login::SESSION_KEY] =
        create(:person, email: 'test.user@digital.justice.gov.uk', super_admin: super_admin).id
    end

    def current_user
      Person.where(email: 'test.user@digital.justice.gov.uk').first
    end

    def omni_auth_log_in_as(email)
      OmniAuth.config.test_mode = true

      OmniAuth.config.mock_auth[:ditsso_internal] = OmniAuth::AuthHash.new(
        provider: 'ditsso_internal',
        info: {
          email: email,
          first_name: 'John',
          last_name: 'Doe',
          name: 'John Doe'
        }
      )

      visit '/auth/ditsso_internal'
    end

    def omni_auth_log_in_as_super_admin
      omni_auth_log_in_as create(:super_admin).email
    end
  end
end
