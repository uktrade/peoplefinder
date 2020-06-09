# frozen_string_literal: true

module PeopleHelper
  def profile_field(record, field, &content_block)
    return if record.public_send(field).blank?

    content_block ||= -> { record.public_send(field).to_s }
    title = t(field, scope: [:profile, record.model_name.singular])

    render(layout: 'people/profile_field', locals: { title: title }, &content_block)
  end

  def working_days_to_sentence(person)
    working_week = [
      person.works_monday, person.works_tuesday, person.works_wednesday,
      person.works_thursday, person.works_friday
    ]
    weekend = [person.works_saturday, person.works_sunday]

    if working_week.all? && weekend.none?
      t('works_weekdays', scope: :days)
    elsif working_week.none? && weekend.none?
      t('works_none', scope: :days)
    else
      Person::DAYS_WORKED
        .select { |day| person[day] }
        .map { |day| t(day, scope: :days) }
        .to_sentence
    end
  end

  # --------------------------------------------------------------------------
  # TODO: Helpers below need to be rewritten once we transition from legacy UI
  # --------------------------------------------------------------------------

  # e.g. profile_image_tag person, link: false
  def profile_image_tag(person, options = {})
    source = profile_image_source(person, options)
    options[:link_uri] = person_path(person) if add_image_link?(options)
    options[:alt_text] = "Current photo of #{person}"
    profile_or_team_image_div source, options
  end

  def team_image_tag(team, options = {})
    source = 'medium_team.png'
    options[:link_uri] = group_path(team) if add_image_link?(options)
    options[:alt_text] = "Team icon for #{team.name}"
    profile_or_team_image_div source, options
  end

  # Why do we need to go to this trouble to repeat new_person/edit_person? you
  # might wonder. Well, form_for only allows us to replace the form class, not
  # augment it, and we rely on the default classes elsewhere.
  #
  def person_form_class(person, activity)
    [person.new_record? ? 'new_person' : 'edit_person'].tap do |classes|
      classes << 'completing' if activity == 'complete'
    end.join(' ')
  end

  private

  def image_tag_wrapper(source, options)
    image_tag(
      source.respond_to?(:url) ? source.url : source,
      options
        .except(:version, :link, :link_uri, :alt_text)
        .merge(alt: options[:alt_text], class: 'media-object')
    )
  end

  def profile_or_team_image_div(source, options)
    tag.div(class: 'maginot') do
      if options.key?(:link_uri)
        tag.a(href: options[:link_uri]) do
          image_tag_wrapper(source, options)
        end
      else
        image_tag_wrapper(source, options)
      end
    end
  end

  # default to having an image link unless 'link: false' passed explicitly
  def add_image_link?(options)
    !options.key?(:link) || options[:link]
  end

  def profile_image_source(person, options)
    version = options.fetch(:version, :medium)
    url_for_image person.profile_image.try(version)
  end

  def url_for_image(image)
    if image.try(:file).respond_to? :authenticated_url
      image.file.authenticated_url
    else
      image || 'medium_no_photo.png'
    end
  end

  def building_names
    I18n.t('people.building_names').each_pair do |k, v|
      [k, v]
    end.sort
  end

  def key_skill_names
    I18n.t('people.key_skill_names').each_pair do |k, v|
      [k, v]
    end.sort
  end

  def grade_names
    I18n.t('people.grade_names').each_pair do |k, v|
      [v, k]
    end.sort
  end

  def learning_and_development_names
    I18n.t('people.learning_and_development_names').each_pair do |k, v|
      [k, v]
    end.sort
  end

  def network_names
    I18n.t('people.network_names').each_pair do |k, v|
      [k, v]
    end.sort
  end

  def profession_names
    I18n.t('people.profession_names').each_pair do |k, v|
      [k, v]
    end.sort
  end

  def key_responsibility_names
    I18n.t('people.key_responsibility_names').each_pair do |k, v|
      [k, v]
    end.sort
  end

  def additional_responsibility_names
    I18n.t('people.additional_responsibility_names').each_pair do |k, v|
      [k, v]
    end.sort
  end
end
