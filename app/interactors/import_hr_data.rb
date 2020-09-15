# frozen_string_literal: true

require 'csv'

class ImportHrData
  include Interactor

  def call
    check_data_coherence
    import_data
  end

  private

  def check_data_coherence
    first_row = HrDataRow.from_csv_row(csv.second)
    return if first_row.valid?

    context.fail!(error: "Coherence check on first row of data failed: #{first_row.errors.full_messages.join(', ')}")
  end

  def import_data
    csv.drop(1).each do |row|
      UpdatePersonFromHrImportWorker.perform_async(row)
    end
  end

  def csv
    @csv = CSV.read(context.csv_file.path)
  rescue CSV::MalformedCSVError
    context.fail!(error: 'Could not read uploaded file - is it definitely in CSV format?')
  end
end
