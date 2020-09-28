# frozen_string_literal: true

class UpdatePersonFromHrImportWorker
  include Sidekiq::Worker

  def perform(hr_data_row)
    record = HrDataRow.from_csv_row(hr_data_row)

    if record.invalid?
      error_msg = record.errors.full_messages.join(', ')
      Rails.logger.error("[hr-data-import] Could not parse record (#{hr_data_row.join(',')}): #{error_msg}")
      return
    end

    person = Person.find_by(email: record.email)

    unless person
      Rails.logger.warn("[hr-data-import] Could not match record '#{record.email}' to a People Finder user")
      Rails.logger.info("[DATA] #{hr_data_row.join(',')},does not exist,")
      return
    end

    previous_grade = person.grade.to_s
    previous_grade_old = HrDataRow::GRADE_MAPPINGS.key(person.grade&.to_sym) || person.grade&.humanize
    if previous_grade == record.mapped_grade.to_s
      Rails.logger.info("[hr-data-import] Grade for user '#{record.email}' has not changed")
      Rails.logger.info("[DATA] #{hr_data_row.join(',')},grade matches already,#{previous_grade_old}")
      return
    end

    PaperTrail.request(whodunnit: 'HR Data Import') do
      person.update(grade: record.mapped_grade)
    end

    if previous_grade.present?
      Rails.logger.info("[DATA] #{hr_data_row.join(',')},grade would change,#{previous_grade_old}")
      Rails.logger.info(
        "[hr-data-import] Changed grade for user '#{record.email}' to #{record.mapped_grade} (was #{previous_grade})"
      )
    else
      Rails.logger.info("[DATA] #{hr_data_row.join(',')},grade would be set,")
      Rails.logger.info("[hr-data-import] Set grade for user '#{record.email}' to #{record.mapped_grade}")
    end
  end
end
