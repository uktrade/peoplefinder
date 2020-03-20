# frozen_string_literal: true

class Membership < ApplicationRecord
  has_paper_trail versions: { class_name: 'Version' },
                  ignore: %i[updated_at created_at id]

  belongs_to :person, touch: true
  belongs_to :group, touch: true

  validates :person, presence: true, on: :update
  validates :group, presence: true, on: %i[create update]
  validates_with PermanentSecretaryUniqueValidator

  delegate :name, to: :person, prefix: true
  delegate :image, to: :person, prefix: true
  delegate :name, to: :group, prefix: true, allow_nil: true
  delegate :path, to: :group

  def to_s
    [group_name, role].map(&:presence).compact.join(', ')
  end

  before_destroy { |m| UpdateGroupMembersCompletionScoreJob.perform_later(m.group) }
end
