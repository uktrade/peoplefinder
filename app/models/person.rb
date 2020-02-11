# frozen_string_literal: true

class Person < ApplicationRecord
  attr_accessor :working_days

  include Completion
  include FormFieldOptions
  include PersonChangesTracker
  include ProfileFields
  include Sanitizable
  include Searchable

  belongs_to :profile_photo

  extend FriendlyId
  friendly_id :slug_source, use: :slugged

  def slug_source
    email.present? ? Digest::SHA1.hexdigest(email.split(/@/).first) : name
  end

  def as_indexed_json(_options = {})
    as_json(
      only: %i[surname email],
      methods: %i[
        name role_and_group location languages phone_number_variations
        formatted_key_skills formatted_learning_and_development
      ]
    )
  end

  has_paper_trail versions: { class_name: 'Version' },
                  on: %i[create destroy update],
                  ignore: %i[updated_at created_at id slug login_count last_login_at]

  sanitize_fields :given_name, :surname, strip: true, remove_digits: true
  sanitize_fields :email, strip: true, downcase: true

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_save :crop_profile_photo
  after_save :enqueue_group_completion_score_updates

  attr_accessor :skip_group_completion_score_updates
  skip_callback :save, :after, :enqueue_group_completion_score_updates, if: :skip_group_completion_score_updates

  def enqueue_group_completion_score_updates
    groups_prior = groups
    reload # updates groups
    groups_current = groups

    (groups_prior + groups_current).uniq.each do |group|
      UpdateGroupMembersCompletionScoreJob.perform_later(group)
    end
  end

  def crop_profile_photo(versions = [])
    profile_photo.crop crop_x, crop_y, crop_w, crop_h, versions if crop_x.present?
  end

  def profile_image
    profile_photo&.image
  end

  validates :ditsso_user_id, presence: true, uniqueness: true
  validates :given_name, presence: true
  attr_accessor :skip_must_have_surname
  validates :surname, presence: true, unless: :skip_must_have_surname
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  has_many :memberships, -> { includes(:group).order('groups.name') }, dependent: :destroy
  has_many :groups, through: :memberships
  attr_accessor :skip_must_have_team
  validate :must_have_team, unless: :skip_must_have_team

  accepts_nested_attributes_for :memberships, allow_destroy: true

  default_scope { order(surname: :asc, given_name: :asc) }

  scope :all_in_subtree, lambda { |group|
    joins(:memberships)
      .where(memberships: { group_id: group.subtree_ids })
      .select("people.*,
            string_agg(CASE role WHEN '' THEN NULL ELSE role END, ', ' ORDER BY role) AS role_names")
      .group(:id)
  }

  def self.outside_subteams(group)
    unscope(:order)
      .joins(:memberships)
      .where(memberships: { group_id: group.id })
      .where(memberships: { leader: false })
      .where('NOT EXISTS (SELECT 1 FROM memberships m2 WHERE m2.person_id = people.id AND m2.group_id != ?)', group.id)
      .distinct
  end

  # Does not return ActiveRecord::Relation
  # - see all_in_groups_scope alternative
  # TODO: remove when not needed
  def self.all_in_groups(group_ids)
    query = <<-SQL
    SELECT DISTINCT p.*,
        string_agg(CASE role WHEN '' THEN NULL ELSE role END, ', ' ORDER BY role) AS role_names
      FROM memberships m, people p
      WHERE m.person_id = p.id AND m.group_id in (?)
      GROUP BY p.id
      ORDER BY surname ASC, given_name ASC;
    SQL
    find_by_sql([query, group_ids])
  end

  def self.count_in_groups(group_ids, excluded_group_ids: [], excluded_ids: [])
    excluded_ids += Person.in_groups(excluded_group_ids).pluck(:id) if excluded_group_ids.present?

    Person.in_groups(group_ids).where.not(id: excluded_ids).count
  end

  def self.in_groups(group_ids)
    Person.includes(:memberships)
          .where("memberships.group_id": group_ids)
  end

  def to_s
    name
  end

  def role_and_group
    memberships.join('; ')
  end

  def languages
    [language_fluent, language_intermediate].compact.reject(&:empty?).join(', ')
  end

  def path
    groups.any? ? groups.first.path + [self] : [self]
  end

  def phone
    [primary_phone_number, secondary_phone_number].find(&:present?)
  end

  # Normalises the different ways in which people may search for phone numbers
  def phone_number_variations
    return nil unless phone

    base_phone = phone.gsub(/[^\d]/, '')
    phone_with_prefix = "#{primary_phone_country.country_code}#{base_phone.gsub(/^0/, '')}" if primary_phone_country
    phone_starting_with_zero = "0#{base_phone}" unless /^[0\+]/.match?(base_phone)

    [base_phone, phone_with_prefix, phone_starting_with_zero].compact
  end

  def primary_phone_country
    primary_phone_country_code.present? ? ISO3166::Country.new(primary_phone_country_code) : nil
  end

  def secondary_phone_country
    secondary_phone_country_code.present? ? ISO3166::Country.new(secondary_phone_country_code) : nil
  end

  include ConcatenatedFields
  concatenated_field :location, :location_in_building, :building, :city, join_with: ', '
  concatenated_field :name, :given_name, :surname, join_with: ' '

  def notify_of_change?(person_responsible)
    person_responsible.try(:email) != email
  end

  def country_name
    country_obj = ISO3166::Country[country]
    country_obj ? country_obj.translations[I18n.locale.to_s] : country
  end

  private

  def must_have_team
    errors.add(:membership, 'of a team is required') if memberships.reject(&:marked_for_destruction?).empty?
  end
end
