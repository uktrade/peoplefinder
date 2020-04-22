# frozen_string_literal: true

class Mailchimp
  def initialize(mailchimp_client: Gibbon::Request.new)
    @mailchimp_client = mailchimp_client
  end

  def create_or_update_subscriber(email, merge_fields: {})
    # Upsert the subscriber details because there may or may not be an existing subscriber
    # for any given email address (c.f. #deactivate_subscriber)
    upsert_member(email, email_address: email, status: 'subscribed', merge_fields: merge_fields)
  end

  def deactivate_subscriber(email)
    # Once a subscriber is deleted from Mailchimp, the same email can *never* be used on that
    # list again. Therefore, we set the subscriber status for that email to "cleaned" instead
    # so they are no longer included in campaigns, and if that email comes back into existence
    # one day it can be upserted to "subscribed" again.
    upsert_member(email, status: 'cleaned')
  end

  private

  attr_reader :mailchimp_client

  def upsert_member(email, options)
    md5_of_lowercase_email = Digest::MD5.hexdigest(email.downcase)

    mailchimp_client
      .lists(list_id)
      .members(md5_of_lowercase_email)
      .upsert(body: options)
  end

  def list_id
    Rails.configuration.mailchimp_list_id
  end
end
