# frozen_string_literal: true

module Concerns::FormFieldOptions
  extend ActiveSupport::Concern

  included do
    WEEK_DAYS = %i[
      works_monday
      works_tuesday
      works_wednesday
      works_thursday
      works_friday
    ].freeze

    DAYS_WORKED = [
      *WEEK_DAYS,
      :works_saturday,
      :works_sunday
    ].freeze

    def works_weekends?
      works_saturday || works_sunday
    end

    BUILDING_OPTS = %i[
      whitehall_55
      whitehall_3
      victoria_50
      horse_guards
      king_charles
    ].freeze
  end
end
