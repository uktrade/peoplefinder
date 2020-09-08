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
    options_with_alt = options.reverse_merge(alt: "Profile picture of #{person.name}")

    return image_pack_tag('medium_no_photo.png', **options_with_alt) if person.profile_image.blank?

    image = person.profile_image.medium
    source = if image.file.respond_to?(:authenticated_url)
               image.file.authenticated_url
             else
               image.url
             end

    image_tag(source, options_with_alt)
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
