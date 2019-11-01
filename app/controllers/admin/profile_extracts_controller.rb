# frozen_string_literal: true

module Admin
  class ProfileExtractsController < ApplicationController
    include ApplicationHelper

    require 'csv'
    before_action :authorize_user

    def show
      respond_to do |format|
        format.csv do
          send_data people_csv, filename: "profiles-#{Time.zone.today}.csv"
        end
      end
    end

    private

    def people_csv
      @people = Person.includes(memberships: [:group]).order(:given_name)

      CSV.generate(headers: true) do |csv|
        csv << profile_headers
        @people.each do |person|
          csv << person_row(person)
        end
      end
    end

    def profile_headers
      %w[
        SSOUserId
        Firstname Surname Email
        AddressLondonOffice AddressOtherUKRegional AddressOtherOverseas
        LocationInBuilding
        City Country JobTitle
        LastLogin ProfileCompletionScore
        TeamId TeamName
        PrimaryPhoneNumber
        SecondaryPhoneNumber
      ]
    end

    def person_row(person) # rubocop:disable Metrics/MethodLength
      membership = person.memberships.first
      [
        person.ditsso_user_id,
        person.given_name, person.surname, person.email,
        person.formatted_buildings, person.other_uk, person.other_overseas,
        person.location_in_building,
        person.city, person.country_name, membership.try(:role),
        person.last_login_at, person.completion_score,
        membership.try(:group).try(:id), membership.try(:group).try(:name),
        phone_number_with_country_code(
          person.primary_phone_country,
          person.primary_phone_number
        ),
        phone_number_with_country_code(
          person.secondary_phone_country,
          person.secondary_phone_number
        )
      ]
    end

    def authorize_user
      authorize 'Admin::Management'.to_sym, :csv_extract_report?
    end
  end
end
