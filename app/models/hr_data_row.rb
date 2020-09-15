# frozen_string_literal: true

class HrDataRow
  EXPECTED_NUM_COLUMNS = 6
  EMAIL_COLUMN = 4
  GRADE_COLUMN = 3

  GRADE_MAPPINGS = {
    'unspecified' => nil,
    'SCS4 Level' => :scs_4,
    'SCS3 Level' => :scs_3,
    'SCS2 Level' => :scs_2,
    'SCS1 Level' => :scs_1,
    'G6 Level' => :grade_6,
    'G7 Level' => :grade_7,
    'SEO Level' => :senior_executive_officer,
    'HEO Level' => :higher_executive_officer,
    'EO Level' => :executive_officer,
    'AO Level' => :admin_officer,
    'AA Level' => :admin_assistant,
    'Faststream Level' => :fast_stream,
    'Intern' => :intern
  }.freeze

  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include Sanitizable

  attr_accessor :email, :grade

  validates :email, presence: true, email_address: true
  validate :grade_is_correct_format

  sanitize_fields :email, strip: true, downcase: true

  def self.from_csv_row(row)
    new(email: row[EMAIL_COLUMN], grade: row[GRADE_COLUMN])
  end

  def mapped_grade
    GRADE_MAPPINGS[grade]
  end

  private

  def grade_is_correct_format
    errors.add(:grade, "is an unexpected value ('#{grade}')") if GRADE_MAPPINGS.keys.exclude?(grade)
  end
end
