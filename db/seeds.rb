# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_bot'

dit = Group.create!(name: 'Department for International Trade', acronym: 'DIT')
coo = Group.create!(name: 'Chief Operating Officer (Corporate Functions)', acronym: 'COO', parent: dit)
ddat = Group.create!(name: 'Digital, Data and Technology', acronym: 'DDaT', parent: coo)

groups = [dit, coo, ddat] + Group.create!([
  { name: 'Marketing', parent: dit },
  { name: 'GREAT', parent: dit },
  { name: 'Finance', parent: coo },
  { name: 'Digital', parent: ddat },
  { name: 'Data', parent: ddat },
  { name: 'Technology', parent: ddat }
])

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
