require 'rails_helper'

RSpec.describe ReminderMailer do
  include PermittedDomainHelper

  let(:person) { create(:person, given_name: 'John', surname: 'Coe', email: 'test.user@digital.justice.gov.uk') }

  let(:group)  do
    team = create(:group)
    team.people << person
    person.reload
    person.memberships.first.update(leader: true)
    team
  end

  shared_examples 'sets email to and from correctly' do
    it 'sets the sender' do
      expect(mail.from).to include(Rails.configuration.support_email)
    end

    it 'sets the correct recipient' do
      expect(mail.to).to include(person.email)
    end
  end

  shared_examples 'subject contains' do |subject|
    it 'sets the subject' do
      expect(mail.subject).to have_text(subject)
    end
  end

  shared_examples 'body contains' do |text|
    it 'includes body text' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(text)
      end
    end
  end

  shared_examples 'includes link to edit person' do
    it 'includes the person edit url' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(edit_person_url(person))
      end
    end
  end

  shared_examples 'includes link to edit group' do
    it 'includes the person edit url' do
      edit_url = edit_group_url(group)
      html = get_message_part(mail, 'html')
      expect(html).to have_link('your team’s information', href: edit_url)
      expect(html).to have_link(edit_url, href: edit_url)

      plain_text = get_message_part(mail, 'plain')
      expect(plain_text).to have_text(edit_url)
    end
  end

  shared_examples 'includes link to token login' do
    it 'includes the token login url' do
      expect(get_message_part(mail, 'text')).to have_text('http://www.example.com/tokens/')
    end
  end

  describe '.never_logged_in' do
    let(:mail) { described_class.never_logged_in(person).deliver_now }

    include_examples 'common mailer template elements'
    include_examples 'sets email to and from correctly'
    include_examples 'subject contains', 'Are your People Finder details up to date?'
    include_examples 'body contains', 'Hello John'
    include_examples 'includes link to token login'
  end

  describe '.team_description_missing' do
    let(:mail) { described_class.team_description_missing(person, group).deliver_now }

    include_examples 'common mailer template elements'
    include_examples 'sets email to and from correctly'
    include_examples 'subject contains', 'Improve your team’s profile on People Finder'
    include_examples 'body contains', 'Hello John'
    include_examples 'includes link to edit group'
  end

  describe '.person_profile_update' do
    let(:mail) { described_class.person_profile_update(person).deliver_now }

    include_examples 'common mailer template elements'
    include_examples 'sets email to and from correctly'
    include_examples 'subject contains', 'Are your People Finder details up to date?'
    include_examples 'body contains', 'Hello John'
    include_examples 'includes link to token login'

    it 'includes profile details' do
      team_name = group.name # also creates group
      %w(html plain).each do |type|
        text = get_message_part(mail, type)
        expect(text).to have_text('Name John Coe')
        expect(text).to have_text("Team #{team_name} - you are a team leader")
        expect(text).to have_text('Role -')
        expect(text).to have_text('Location -')
        expect(text).to have_text('Primary phone number -')
        expect(text).to have_text('Current project(s) -')
      end
    end
  end

end
