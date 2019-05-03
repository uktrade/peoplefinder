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
        City Country JobTitle
        LastLogin ProfileCompletionScore
        Team
        PrimaryPhoneNumber
      ]
    end

    def person_row(person) # rubocop:disable Metrics/AbcSize
      [
        person.ditsso_user_id,
        person.given_name, person.surname, person.email,
        person.formatted_buildings, person.other_uk, person.other_overseas,
        person.city, person.country_name, person.memberships.first.try(:role),
        person.last_login_at, person.completion_score,
        person.memberships.first.try(:group).try(:name),
        phone_number_with_country_code(
          person.primary_phone_country,
          person.primary_phone_number
        )
      ]
    end

    def authorize_user
      authorize 'Admin::Management'.to_sym, :csv_extract_report?
    end
  end
end
