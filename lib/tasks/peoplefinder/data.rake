# frozen_string_literal: true

namespace :peoplefinder do
  namespace :data do
    DOMAIN = 'fake-moj.justice.gov.uk'

    class DemoGroupMemberships
      extend Forwardable

      attr_reader :group_membership
      def_delegators :group_membership, :each, :map, :[], :sample, :size

      def initialize
        create_groups
      end

      def create_groups
        dit = Group.where(ancestry_depth: 0).first_or_create!(
          name: 'Department for International Trade',
          acronym: 'DIT'
        )
        coo = Group.find_or_create_by!(
          name: 'Chief Operating Officer (Corporate Services)',
          acronym: 'COO',
          parent: dit
        )
        finance = Group.find_or_create_by!(name: 'Finance', acronym: 'Fin', parent: coo)
        ddat = Group.find_or_create_by!(name: 'Digital, Data and Technology', acronym: 'DDaT', parent: coo)
        cn = Group.find_or_create_by!(name: 'Content', parent: ddat)
        dev = Group.find_or_create_by!(name: 'Development', parent: ddat)
        ops = Group.find_or_create_by!(name: 'Webops', parent: ddat)

        @group_membership = [[dit, 1], [coo, 1], [finance, 2], [ddat, 2], [cn, 1], [dev, 3], [ops, 2]]
      end
    end

    # peoplefinder:data:demo
    #
    # idempotent for groups but will add members
    # when run repeatedly.
    #
    # Group demo data structure is as below (left to right):
    #
    # dit > coo > digital services > content
    #           |                  |
    #           |                  |
    #           > finance          > development
    #                              |
    #                              |
    #                              > webops
    #
    desc 'create basic demonstration data'
    task demo: :environment do
      DemoGroupMemberships.new.each do |group, member_count|
        RandomGenerator.new(group).generate_members(member_count, DOMAIN)
      end
      puts 'Generated random basic demonstration data'
      Rake::Task['peoplefinder:data:search_scenario_1'].invoke
      Rake::Task['peoplefinder:es:index_people'].invoke
    end

    desc 'generate data for steve\'s search scenario'
    task search_scenario_1: %i[environment demo] do
      names = [
        'Steve Richards',
        'Steven Richards',
        'Stephen Richards',
        'Steve Richardson',
        'Steven Richardson',
        'Stephen Richardson',
        'John Richards',
        'Pauline Richards',
        'Steve Edmundson',
        'Steven Edmundson',
        'Stephen Edmundson',
        'John Richardson',
        'John Edmundson',
        'Personal Assistant'
      ]

      demo_groups = DemoGroupMemberships.new

      names.each do |name|
        given_name = name.split.first
        surname = name.split.second
        email = "#{given_name.downcase}.#{surname.downcase}@#{DOMAIN}"
        ditsso_user_id = SecureRandom.uuid

        Person.find_or_initialize_by(
          given_name: given_name,
          surname: surname,
          email: email,
          ditsso_user_id: ditsso_user_id
        ).tap do |person|
          membership = Membership.new(person_id: person.id, group_id: demo_groups.sample.first.id)
          person.memberships << membership if person.memberships.empty?
          person.description = 'PA to Steve Richards' if email == "personal.assistant@#{DOMAIN}"
          person.save!
        end
      end

      puts 'Generated data for steve\'s search scenario'
    end

    namespace :migration do
      def department
        @department ||= Group.department
      end

      desc 'Adds people not in a team to the Department level team'
      task move_unassigned_to_department: :environment do
        puts "Assign #{Person.non_team_members.count} people not in a team to #{department}"
        Person.non_team_members.each do |person|
          person.memberships.create(group: department)
          print '.'
        rescue StandardError => e
          puts "Failed to assign #{person.name} to #{department}: #{e}"
        end
      end

      desc 'Deletes department level team memberships with no role for people with memberships in another team'
      task remove_unnecessary_department_memberships: :environment do
        puts "Remove #{Person.department_members_in_other_teams.count} unnecessary #{department} memberships"
        Person.department_members_in_other_teams.each do |person|
          person.department_memberships_with_no_role.destroy_all
        end
      end
    end
  end
end
