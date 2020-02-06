# frozen_string_literal: true

FactoryBot.define do
  sequence(:email) { |n| format('example.user.%d@trade.gov.uk', n) }
  sequence(:given_name) { |n| "First name #{('a'.ord + (n % 25)).chr}" }
  sequence(:surname) { |n| "Surname #{('a'.ord + (n % 25)).chr}" }
  sequence(:location_in_building) { |n| "Room #{n}, #{n.ordinalize}" }
  sequence(:city) { |n| format('Megacity %d', n) }
  sequence(:country) { |n| format('Country %d', n) }
  sequence(:primary_phone_number) { |n| format('07708 %06d', (900_000 + n)) }
  sequence(:pager_number) { |n| format('07600 %06d', (900_000 + n)) }
  sequence(:phone_number) { |n| format('07700 %06d', (900_000 + n)) }
  sequence(:ditsso_user_id) { |n| format('00000000-0000-0000-0000-00000000%04d', n) }

  factory :department, class: 'Group' do
    initialize_with do
      Group.where(ancestry_depth: 0).first_or_create(name: 'Department for International Trade')
    end
  end

  factory :group do
    sequence :name do |n|
      format('Group-%04d', n)
    end
    association :parent, factory: :department
  end

  factory :membership do
    person
    group

    factory :membership_default do
      role { nil }
      leader { false }
      group_id { create(:department).id }
    end
  end

  factory :person do
    given_name
    surname
    email
    ditsso_user_id

    # validation requires team membership existence
    after :build do |peep, _evaluator|
      department = create(:department)
      peep.memberships << build(:membership, group: department, person: nil) if peep.memberships.empty?
    end

    trait :with_details do
      primary_phone_number
      pager_number
      country
      city
    end

    trait :with_random_dets do
      given_name { Faker::Name.unique.first_name }
      surname { Faker::Name.unique.last_name }
      email { "#{given_name}.#{surname}@example.com" }
      pronouns { 'pronoun1 pronoun2 pronoun3' }
      primary_phone_number { Faker::PhoneNumber.phone_number }
      login_count { Random.rand(1..20) }
      last_login_at { login_count == 0 ? nil : Random.rand(15).days.ago }
      country { Faker::Address.country_code }
    end

    trait :with_photo do
      association :profile_photo, factory: :profile_photo
    end

    # i.e. person in a group with ancestry of 1+
    trait :team_member do
      after(:build) do |p|
        create(:membership, person: p, role: Faker::Job.title)
      end
    end

    trait :member_of do
      transient do
        team { nil }
        leader { false }
        role { nil }
        sole_membership { false }
      end
      after(:build) do |peep, evaluator|
        if peep.memberships.map(&:group).include? evaluator.team
          memberships = peep.memberships.select { |m| m.group == evaluator.team }
          memberships.each do |membership|
            membership.assign_attributes(leader: evaluator.leader, role: evaluator.role)
          end
        else
          peep.memberships << build(:membership, group: evaluator.team, person: peep, leader: evaluator.leader, role: evaluator.role)
        end
        peep.memberships = peep.memberships.select { |m| m.group_id == evaluator.team.id } if evaluator.sole_membership
      end
    end

    # i.e. unassigned person - person in group with ancestry of 0 (i.e. DIT)
    trait :department_member do
      after(:build) do |p|
        department = create(:department)
        create(:membership, person: p, group: department)
      end
    end

    factory :person_with_multiple_logins do
      login_count { 10 }
      last_login_at { 1.day.ago }
    end

    factory :super_admin do
      super_admin { true }
    end
  end

  factory :profile_photo do
    image do
      Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'spec', 'fixtures', 'profile_photo_valid.png')
      )
    end

    trait :invalid_extension do
      image do
        Rack::Test::UploadedFile.new(
          File.join(Rails.root, 'spec', 'fixtures', 'placeholder.bmp')
        )
      end
    end

    trait :too_small_dimensions do
      image do
        Rack::Test::UploadedFile.new(
          File.join(Rails.root, 'spec', 'fixtures', 'profile_photo_too_small_dimensions.png')
        )
      end
    end

    trait :large_dimensions do
      image do
        Rack::Test::UploadedFile.new(
          File.join(Rails.root, 'spec', 'fixtures', 'profile_photo_large.png')
        )
      end
    end
  end
end
