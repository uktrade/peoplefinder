# frozen_string_literal: true

require 'rails_helper'

describe 'Administrator views CSV extracts' do
  before do
    omni_auth_log_in_as_administrator
    click_link 'Manage'
  end

  it 'download of profiles' do
    within('#profiles-download') { click_link 'Download' }

    header = page.response_headers['Content-Disposition']
    expect(header).to match(/^attachment/)
    expect(header).to match(/filename="profiles-.*.csv"/)

    expect(page).to have_text('Firstname,Surname,Email')

    person = Person.last
    person_fields = "#{person.given_name},#{person.surname},#{person.email}"
    expect(page).to have_text(person_fields)
  end

  it 'download of teams' do
    within('#teams-download') { click_link 'Download' }

    header = page.response_headers['Content-Disposition']
    expect(header).to match(/^attachment/)
    expect(header).to match(/filename="teams-.*.csv"/)

    expect(page).to have_text('TeamId,TeamName,ParentId,Ancestry')

    group = Group.last
    group_fields = "#{group.id},#{group.name},#{group.parent_id},#{group.ancestry}"
    expect(page).to have_text(group_fields)
  end
end
