# frozen_string_literal: true

require 'notifications/client'

# A wrapper for the GOV.UK Notify client
class GovukNotify
  UPDATED_PROFILE_TEMPLATE = 'acfdc019-22d1-4281-aab9-3f64764425ac'
  DELETED_PROFILE_TEMPLATE = '92a1992f-96d7-4f59-af30-e2432aa004d0'

  def initialize
    @client = Notifications::Client.new(Rails.configuration.govuk_notify_api_key)
  end

  def updated_profile(recipient_email, recipient_name:, instigator_name:, profile_url:)
    @client.send_email(
      email_address: recipient_email,
      template_id: UPDATED_PROFILE_TEMPLATE,
      personalisation: {
        recipient_name: recipient_name,
        instigator_name: instigator_name,
        profile_url: profile_url
      }
    )
  end

  def deleted_profile(recipient_email, recipient_name:)
    @client.send_email(
      email_address: recipient_email,
      template_id: DELETED_PROFILE_TEMPLATE,
      personalisation: {
        recipient_name: recipient_name
      }
    )
  end
end
