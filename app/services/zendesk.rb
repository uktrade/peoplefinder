# frozen_string_literal: true

class Zendesk
  def report_problem(reporter:, params:)
    zendesk_request_fields = [
      { id: '45490089', value: params['problem_report_goal'] },
      { id: '45522325', value: params['problem_report_problem'] },
      { id: '45522345', value: params['problem_report_origin'] },
      { id: '34146805', value: params['problem_report_browser'] },
      { id: '45522485', value: params['problem_report_email'] },
      { id: zendesk_config.service_id, value: zendesk_config.service_name }
    ]

    client.tickets.create!(
      subject: "People Finder problem report (#{Time.current})",
      comment: { value: params['problem_report_problem'] },
      submitter_id: client.current_user.id,
      priority: 'normal',
      type: 'incident',
      custom_fields: zendesk_request_fields,
      requester: { email: reporter.email, name: reporter.name }
    )
  end

  def request_deletion(reporter:, person_to_delete:, note:)
    person_url = Rails.application.routes.url_helpers.person_url(person_to_delete)

    comment = <<~COMMENT
      Profile deletion request

      Profile name: #{person_to_delete.name}
      Profile URL: #{person_url}

      Reported by: #{reporter.name}
      Reporter email: #{reporter.email}

      Note:
      #{note}
    COMMENT

    client.tickets.create!(
      subject: "People Finder deletion request: #{person_to_delete.name}",
      comment: { value: comment },
      submitter_id: client.current_user.id,
      priority: 'normal',
      type: 'incident',
      requester: { email: reporter.email, name: reporter.name }
    )
  end

  private

  def client
    @client ||= ZendeskAPI::Client.new do |config|
      config.url = zendesk_config.url
      config.username = zendesk_config.user
      config.password = zendesk_config.password
      config.retry = true
      config.logger = Logger.new(STDOUT)
    end
  end

  def zendesk_config
    Rails.configuration.x.zendesk
  end
end
