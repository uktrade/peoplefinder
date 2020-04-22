# frozen_string_literal: true

class Mailchimp
  def initialize(mailchimp_client: Gibbon::Request.new)
    @mailchimp_client = mailchimp_client
  end

  def create_or_update_subscriber(email, merge_fields: {})
    # Upsert the subscriber details because there may or may not be an existing subscriber
    # for any given email address (c.f. #deactivate_subscriber)
    body = {
      email_address: email,
      status: 'subscribed',
      merge_fields: merge_fields
    }
    member_for(email).upsert(body: body)
  end

  def set_subscriber_tags(email, tags: [])
    # The Mailchimp API does not allow us to set a subscriber's tags to a specific set of tags.
    # We need to explicitly set all tags we want to remove to `inactive` instead of just leaving
    # them out, so this requires us to figure out what existing tags a user has.
    current_tags = member_for(email).retrieve.body['tags'].map { |tag| tag['name'] }

    inactive_tags = current_tags
                    .reject { |tag| tags.include?(tag) }
                    .map { |tag| { name: tag, status: 'inactive' } }
    active_tags = tags.map { |tag| { name: tag, status: 'active' } }

    member_for(email).tags.create(body: { tags: inactive_tags + active_tags })
  end

  def deactivate_subscriber(email)
    # Mailchimp has two kinds of delete; this is a "soft" delete which doesn't actually delete the
    # subscriber, but moves them to the "archived" section of the audience. Subscribers that have
    # been archived in this way can be recreated in the future.
    member_for(email).delete
  end

  private

  attr_reader :mailchimp_client

  def member_for(email)
    md5_of_lowercase_email = Digest::MD5.hexdigest(email.downcase)

    mailchimp_client
      .lists(list_id)
      .members(md5_of_lowercase_email)
  end

  def list_id
    Rails.configuration.mailchimp_list_id
  end
end
