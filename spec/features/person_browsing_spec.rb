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

  def create_group_hierarchy(*names)
    group = create(:department)
    names.each do |name|
      group = Group.find_by(name: name) || create(:group, parent: group, name: name)
    end
    group
  end
end
