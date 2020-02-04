# frozen_string_literal: true

# Represents a team and its associated hierarchy
class Group < ApplicationRecord
  include Concerns::Placeholder

  MAX_DESCRIPTION = 1500

  has_ancestry cache_depth: true

  has_paper_trail versions: { class_name: 'Version' },
                  on: %i[create destroy update],
                  ignore: %i[updated_at created_at slug id
                             members_completion_score]

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    return [name] unless parent

    [name, [parent.name, name], [parent.name, name_and_sequence]]
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  has_many :memberships,
           -> { includes(:person).order('people.surname') },
           dependent: :destroy
  has_many :people, through: :memberships
  has_many :leaderships, -> { where(leader: true) }, class_name: 'Membership'
  has_many :leaders, through: :leaderships, source: :person

  def distinct_non_leaderships
    DistinctMembershipQuery.new(group: self, leadership: false).call
  end

  validates :name, presence: true
  validates :slug, uniqueness: true
  validates :description, length: { maximum: MAX_DESCRIPTION }

  validate :only_one_root_group

  before_destroy :check_deletability

  default_scope { order(name: :asc) }

  scope :without_description, -> { unscoped.where(description: ['', nil]) }

  after_save { |group| UpdateGroupMembersCompletionScoreJob.perform_later(group) }

  def self.department
    roots.first
  end

  def self.hierarchy_hash
    arrange(order: :name)
  end

  def self.percentage_with_description
    if count == 0
      0
    else
      100 - (without_description.count / count.to_f * 100).round(0)
    end
  end

  def root_group?
    parent.blank?
  end

  def leaf_node?
    children.blank?
  end

  def to_s
    name
  end

  def short_name
    acronym.presence || name
  end

  def deletable?
    leaf_node? && memberships.reject(&:new_record?).empty?
  end

  def all_people
    Person.all_in_subtree(self)
  end

  def all_people_count
    Person.count_in_groups(subtree_ids)
  end

  def people_outside_subteams
    Person.all_in_groups([id]) - Person.all_in_groups(subteam_ids) - leaders
  end

  def people_outside_subteams_count
    Person.outside_subteams(self).count
  end

  def leaderships_by_person
    leaderships.group_by(&:person)
  end

  def average_completion_score
    people = all_people
    people.blank? ? 0 : Person.average_completion_score(people.pluck(:id))
  end

  def update_members_completion_score!
    score = average_completion_score
    update_columns(members_completion_score: score)
  end

  def editable_parent?
    new_record? || parent.present? || children.empty?
  end

  def subscribers
    memberships.subscribing.joins(:person).map(&:person)
  end

  private

  def only_one_root_group
    # Pass if this isn't a root group
    return if parent_id

    # Pass unless a root group exists that isn't this one
    return unless Group.unscoped.roots.where.not(id: id).exists?

    errors.add(:parent_id, 'is required (a root group/department already exists)')
  end

  def name_and_sequence
    slug = name.to_param
    sequence = Group.where('slug like ?', "#{slug}-%").count + 2
    "#{slug}-#{sequence}"
  end

  def check_deletability
    errors.add :base, :memberships_exist unless deletable?
  end

  def subteam_ids
    subtree_ids - [id]
  end
end
