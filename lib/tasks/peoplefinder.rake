# frozen_string_literal: true

require_relative '../../app/helpers/application_helper'
include ApplicationHelper

namespace :peoplefinder do
  desc 'Merge country codes into phone number field'
  task country_code_merge: :environment do
    PaperTrail.request.whodunnit = 'Automated task: Country code field removal'

    Person.find_each do |person|
      if person.primary_phone_number.present?
        person.primary_phone_number = phone_number_with_country_code(
          person.primary_phone_country, person.primary_phone_number
        )
        person.primary_phone_country_code = nil
      end

      if person.secondary_phone_number.present?
        person.secondary_phone_number = phone_number_with_country_code(
          person.secondary_phone_country, person.secondary_phone_number
        )
        person.secondary_phone_country_code = nil
      end

      person.save if person.changed?
    end
  end

  desc '(Re)index Elasticsearch'
  task reindex: :environment do
    Person.__elasticsearch__.create_index!(index: Person.index_name, force: true)
    Person.import
  end

  desc 'Seed dummy demo data for development'
  task demo: :environment do
    require 'factory_bot'

    dit = Group.create!(name: 'Department for International Trade', acronym: 'DIT')
    coo = Group.create!(name: 'Chief Operating Officer (Corporate Functions)', acronym: 'COO', parent: dit)
    ddat = Group.create!(name: 'Digital, Data and Technology', acronym: 'DDaT', parent: coo)

    groups = [dit, coo, ddat] + Group.create!(
      [
        { name: 'Marketing', parent: dit },
        { name: 'GREAT', parent: dit },
        { name: 'Finance', parent: coo },
        { name: 'Digital', parent: ddat },
        { name: 'Data', parent: ddat },
        { name: 'Technology', parent: ddat }
      ]
    )

    groups.each do |group|
      rand(10).times do
        FactoryBot.create(
          :person,
          :member_of,
          :with_random_dets,
          team: group
        )
      end
    end
  end
end
