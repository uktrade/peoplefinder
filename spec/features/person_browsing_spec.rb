# frozen_string_literal: true

require 'rails_helper'

describe 'Person browsing' do
  let(:department) { create(:department) }

  before do
    department
    omni_auth_log_in_as '007'
  end

  it 'visiting the my/profile path' do
    visit '/my/profile'

    expect(page).to have_current_path(person_path(Digest::SHA1.hexdigest('john.doe')))
  end

  it 'Using breadcrumbs on a profile page' do
    baz = create_group_hierarchy('DIT', 'Foo', 'Bar', 'Baz')
    person = create(:person, :member_of, team: baz)

    visit person_path(person)

    expect(page).to have_selector('.breadcrumbs ol li a', text: 'DIT')
    expect(page).to have_selector('.breadcrumbs ol li a', text: 'Foo')
    expect(page).to have_selector('.breadcrumbs ol li a', text: 'Bar')
    expect(page).to have_selector('.breadcrumbs ol li a', text: 'Baz')
    expect(page).to have_selector('.breadcrumbs ol li', text: person.name)
  end

  describe 'Days worked' do
    let(:weekday_person) { create(:person, works_monday: true, works_friday: true) }
    let(:weekend_person) { create(:person, works_saturday: true, works_sunday: true) }

    it 'A person who only works weekdays should not see Saturday & Sunday listed' do
      visit person_path(weekday_person)
      expect(page).to have_xpath("//li[@alt='Monday']")
      expect(page).to have_xpath("//li[@alt='Friday']")

      expect(page).not_to have_xpath("//li[@alt='Sunday']")
      expect(page).not_to have_xpath("//li[@alt='Saturday']")
    end

    it 'A person who works one or more days on a weekend should have their days listed' do
      visit person_path(weekend_person)

      expect(page).to have_xpath("//li[@alt='Sunday']")
      expect(page).to have_xpath("//li[@alt='Saturday']")
    end
  end

  def create_group_hierarchy(*names)
    group = create(:department)
    names.each do |name|
      group = Group.find_by(name: name) || create(:group, parent: group, name: name)
    end
    group
  end
end
