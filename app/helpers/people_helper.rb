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

  def self_or_other_label(person, field)
    self_or_other_translate(person, field, 'helpers.label.person')
  end

  def self_or_other_hint(person, field)
    self_or_other_translate(person, field, 'helpers.hint.person')
  end

  def self_or_other_translate(person, field, scope)
    if current_user == person
      I18n.t(field, scope: [scope, :self])
    else
      I18n.t(field, scope: [scope, :other], name: person.given_name)
    end
  end

  def team_edit_field_template(form, person:, org_structure:)
    skeleton_membership = Membership.new(group: Group.department, person: person)

    html = form.fields_for(
      :memberships,
      skeleton_membership,
      child_index: 'TEMPLATE_REPLACE'
    ) do |add_membership_fields|
      render 'edit_membership_fields',
             membership_fields: add_membership_fields, org_structure: org_structure, activated: true
    end

    CGI.escapeHTML(html).html_safe # rubocop:disable Rails/OutputSafety
  end

  def profile_picture_image_tag(person, options = {})
    image = person.profile_image.try(:medium)
    source = if image.try(:file).respond_to?(:authenticated_url)
               image.file.authenticated_url
             else
               image || 'medium_no_photo.png'
             end
    source_url = source.respond_to?(:url) ? source.url : source

    options_with_alt = options.reverse_merge(alt: "Profile picture of #{person.name}")

    image_tag(source_url, options_with_alt)
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

  def profile_image_source(person, options = {})
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
    translated_field_pairs('people.building_names')
  end

  def key_skill_names
    translated_field_pairs('people.key_skill_names')
  end

  def grade_names
    translated_field_pairs('people.grade_names')
  end

  def learning_and_development_names
    translated_field_pairs('people.learning_and_development_names')
  end

  def network_names
    translated_field_pairs('people.network_names')
  end

  def profession_names
    translated_field_pairs('people.profession_names')
  end

  def key_responsibility_names
    translated_field_pairs('people.key_responsibility_names')
  end

  def additional_responsibility_names
    translated_field_pairs('people.additional_responsibility_names')
  end

  def translated_field_pairs(scope)
    I18n.t(scope).to_a.sort_by(&:last)
  end
end
