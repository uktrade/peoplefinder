# frozen_string_literal: true

class Person < ApplicationRecord
  DAYS_WORKED = %i[
    works_monday works_tuesday works_wednesday works_thursday works_friday works_saturday works_sunday
  ].freeze
  BUILDING_OPTS = %i[whitehall_55 whitehall_3 victoria_50 horse_guards king_charles].freeze

  # Nowhere near exhaustive list of "insecure" providers, but covers our particular problem cases
  DISALLOWED_EMAIL_DOMAINS = %w[
    aol.com btinternet.com fcowebmail.gov.uk gmail.com hotmail.com hotmail.co.uk outlook.com yahoo.com ymail.com
  ].freeze

  include Completion
  include Sanitizable
  include Searchable

  extend FriendlyId

  default_scope { order(surname: :asc, given_name: :asc) }

  attr_accessor :working_days,
                :crop_x, :crop_y, :crop_w, :crop_h,
                :skip_must_have_surname, :skip_must_have_team, :skip_must_not_have_disallowed_email_domain

  has_many :memberships, -> { includes(:group).order('groups.name') }, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :line_managed_people,
           class_name: 'Person',
           inverse_of: :line_manager,
           dependent: :nullify,
           foreign_key: :line_manager_id
  belongs_to :line_manager,
             class_name: 'Person',
             inverse_of: :line_managed_people,
             optional: true
  belongs_to :profile_photo

  accepts_nested_attributes_for :memberships, allow_destroy: true

  validates :ditsso_user_id, presence: true, uniqueness: true
  validates :given_name, presence: true
  validates :surname, presence: true, unless: :skip_must_have_surname
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :email_is_not_disallowed_domain, unless: :skip_must_not_have_disallowed_email_domain
  validate :line_manager_is_not_self
  validate :line_manager_not_both_specified_and_not_required
  validate :must_have_team, unless: :skip_must_have_team

  after_save :crop_profile_photo
  after_save :enqueue_group_completion_score_updates

  friendly_id :slug_source, use: :slugged

  has_paper_trail versions: { class_name: 'Version' },
                  on: %i[create destroy update],
                  ignore: %i[updated_at created_at id slug login_count last_login_at last_edited_or_confirmed_at]

  paginates_per 40

  sanitize_fields :given_name, :surname, strip: true, remove_digits: true
  sanitize_fields :email, strip: true, downcase: true

  scope :all_in_subtree, lambda { |group|
    joins(:memberships)
      .where(memberships: { group_id: group.subtree_ids })
      .select("people.*, string_agg(CASE role WHEN '' THEN NULL ELSE role END, ', ' ORDER BY role) AS role_names")
      .group(:id)
  }

  def name
    [given_name, surname].map(&:presence).compact.join(' ')
  end

  def location
    [location_in_building, building, city].map(&:presence).compact.join(', ')
  end

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

  def enqueue_group_completion_score_updates
    groups_prior = groups
    reload # updates groups
    groups_current = groups

    (groups_prior + groups_current).uniq.each do |group|
      UpdateGroupMembersCompletionScoreWorker.perform_async(group.id)
    end
  end

  def crop_profile_photo(versions = [])
    profile_photo.crop crop_x, crop_y, crop_w, crop_h, versions if crop_x.present?
  end

  def profile_image
    profile_photo&.image
  end

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
    [base_phone].compact
  end

  def primary_phone_country
    primary_phone_country_code.present? ? ISO3166::Country.new(primary_phone_country_code) : nil
  end

  def secondary_phone_country
    secondary_phone_country_code.present? ? ISO3166::Country.new(secondary_phone_country_code) : nil
  end

  def notify_of_change?(person_responsible)
    person_responsible.try(:email) != email
  end

  def country_name
    country_obj = ISO3166::Country[country]
    country_obj ? country_obj.translations[I18n.locale.to_s] : country
  end

  def stale?
    return unless last_edited_or_confirmed_at

    last_edited_or_confirmed_at < Rails.configuration.profile_stale_after_days.days.ago
  end

  def formatted_buildings
    building.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.building_names')
    end.join(', ')
  end

  def formatted_key_skills
    items = key_skills.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.key_skill_names')
    end.join(', ')
    [items, other_key_skills].compact.reject(&:empty?).join(', ')
  end

  def formatted_learning_and_development
    items = learning_and_development.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.learning_and_development_names')
    end.join(', ')
    [items, other_learning_and_development].compact.reject(&:empty?).join(', ')
  end

  def formatted_networks
    networks.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.network_names')
    end.join(', ')
  end

  def formatted_professions
    professions.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.profession_names')
    end.join(', ')
  end

  def formatted_additional_responsibilities
    items = additional_responsibilities.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.additional_responsibility_names')
    end.join(', ')
    [items, other_additional_responsibilities].compact.reject(&:empty?).join(', ')
  end

  private

  def email_is_not_disallowed_domain
    return if email.blank?

    domain = email.split('@').last&.downcase
    return unless DISALLOWED_EMAIL_DOMAINS.include?(domain)

    errors.add(:email, "is not acceptable (#{domain} addresses are not allowed)")
  end

  def must_have_team
    errors.add(:memberships, :at_least_one_required) if memberships.reject(&:marked_for_destruction?).empty?
  end

  def line_manager_is_not_self
    errors.add(:line_manager, :cannot_be_self) if line_manager == self
  end

  def line_manager_not_both_specified_and_not_required
    return unless line_manager.present? && line_manager_not_required?

    errors.add(:line_manager, :cannot_be_selected_if_not_required)
  end
end
