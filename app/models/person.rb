# frozen_string_literal: true

# == Schema Information
#
# Table name: people
#
#  id                                :integer          not null, primary key
#  given_name                        :text
#  surname                           :text
#  email                             :text
#  primary_phone_number              :text
#  secondary_phone_number            :text
#  location_in_building              :text
#  description                       :text
#  created_at                        :datetime
#  updated_at                        :datetime
#  works_monday                      :boolean          default(TRUE)
#  works_tuesday                     :boolean          default(TRUE)
#  works_wednesday                   :boolean          default(TRUE)
#  works_thursday                    :boolean          default(TRUE)
#  works_friday                      :boolean          default(TRUE)
#  image                             :string
#  slug                              :string
#  works_saturday                    :boolean          default(FALSE)
#  works_sunday                      :boolean          default(FALSE)
#  login_count                       :integer          default(0), not null
#  last_login_at                     :datetime
#  super_admin                       :boolean          default(FALSE)
#  city                              :text
#  secondary_email                   :text
#  profile_photo_id                  :integer
#  last_reminder_email_at            :datetime
#  current_project                   :string
#  pager_number                      :text
#  primary_phone_country_code        :text
#  building                          :string           default([]), is an Array
#  country                           :string
#  skype_name                        :string
#  key_skills                        :string           default([]), is an Array
#  language_fluent                   :text
#  language_intermediate             :text
#  grade                             :text
#  previous_positions                :text
#  learning_and_development          :string           default([]), is an Array
#  networks                          :string           default([]), is an Array
#  additional_responsibilities       :string           default([]), is an Array
#  other_uk                          :text
#  other_overseas                    :text
#  internal_auth_key                 :string
#  other_key_skills                  :string
#  other_learning_and_development    :string
#  other_additional_responsibilities :string
#  professions                       :string           default([]), is an Array
#  other_professions                 :string
#  secondary_phone_country_code      :text
#

class Person < ApplicationRecord
  attr_accessor :working_days

  include Concerns::Acquisition
  include Concerns::Activation
  include Concerns::Completion
  include Concerns::FormFieldOptions
  include Concerns::ExposeMandatoryFields
  include Concerns::GeckoboardDatasets
  include Concerns::PersonChangesTracker
  include Concerns::DataMigrationUtils
  include Concerns::ProfileFields

  belongs_to :profile_photo

  extend FriendlyId
  friendly_id :slug_source, use: :slugged

  def slug_source
    email.present? ? Digest::SHA1.hexdigest(email.split(/@/).first) : name
  end

  include Concerns::Searchable

  def as_indexed_json(_options = {})
    as_json(
      only: %i[surname current_project email],
      methods: %i[
        name role_and_group location languages phone_number_variations
        formatted_key_skills formatted_learning_and_development
      ]
    )
  end

  has_paper_trail class_name: 'Version',
                  ignore: %i[updated_at created_at id slug login_count last_login_at
                             last_reminder_email_at]

  # TODO: eerrh! what is this trying to do, it breaks when attempting to create people with legacy image uploads
  def changes_for_paper_trail
    super.tap do |changes|
      changes['image'].map! { |img| img.url && File.basename(img.url) } if changes.key?('image')
    end
  end

  include Concerns::Sanitizable
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

  mount_uploader :legacy_image, ImageUploader, mount_on: :image, mount_as: :image

  def profile_image
    if profile_photo
      profile_photo.image
    elsif attributes['image']
      legacy_image
    end
  end

  validates :ditsso_user_id, presence: true, uniqueness: true
  validates :given_name, presence: true
  attr_accessor :skip_must_have_surname
  validates :surname, presence: true, unless: :skip_must_have_surname
  validates :email, presence: true, uniqueness: { case_sensitive: false }, email: true
  validates :secondary_email, email: true, allow_blank: true

  has_many :memberships, -> { includes(:group).order('groups.name') }, dependent: :destroy
  has_many :groups, through: :memberships
  attr_accessor :skip_must_have_team
  validate :must_have_team, unless: :skip_must_have_team

  accepts_nested_attributes_for :memberships, allow_destroy: true

  default_scope { order(surname: :asc, given_name: :asc) }

  scope :never_logged_in, PeopleNeverLoggedInQuery.new
  scope :logged_in_at_least_once, PeopleLoggedInAtLeastOnceQuery.new
  scope :last_reminder_email_older_than, ->(within) { ReminderMailOlderThanQuery.new(within).call }
  scope :updated_at_older_than, ->(within) { PeopleUpdatedOlderThanQuery.new(within).call }
  scope :updated_at_older_than, ->(within) { where('updated_at < ?', within) }
  scope :created_at_older_than, ->(within) { where('created_at < ?', within) }

  def email_prefix
    email.split('@').first.gsub(/[\W]|[\d]/, '')
  end

  scope :all_in_groups_scope, ->(groups) { PeopleInGroupsQuery.new(groups).call }

  scope :all_in_subtree, ->(group) { PeopleInGroupsQuery.new(group.subtree_ids).call }

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
    phone_starting_with_zero = "0#{base_phone}" unless base_phone =~ /^[0\+]/

    [base_phone, phone_with_prefix, phone_starting_with_zero].compact
  end

  def primary_phone_country
    primary_phone_country_code.present? ? ISO3166::Country.new(primary_phone_country_code) : nil
  end

  def secondary_phone_country
    secondary_phone_country_code.present? ? ISO3166::Country.new(secondary_phone_country_code) : nil
  end

  include Concerns::ConcatenatedFields
  concatenated_field :location, :location_in_building, :building, :city, join_with: ', '
  concatenated_field :name, :given_name, :surname, join_with: ' '

  def notify_of_change?(person_responsible)
    person_responsible.try(:email) != email
  end

  def reminder_email_sent?(within:)
    last_reminder_email_at.present? &&
      last_reminder_email_at.end_of_day >= within.ago
  end

  def email_address_with_name
    address = Mail::Address.new email
    address.display_name = name
    address.format
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
