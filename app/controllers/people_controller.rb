# frozen_string_literal: true

class PeopleController < ApplicationController
  # TODO: This isn't great but does the trick for now. Refactor!
  before_action do
    next unless params[:id]

    breadcrumbs_group = person.groups.first

    if breadcrumbs_group
      breadcrumbs_group.ancestors.each { |ancestor| breadcrumb ancestor.short_name, ancestor }
      breadcrumb breadcrumbs_group.short_name, breadcrumbs_group
    end

    breadcrumb person.name, person, match: :exact
  end

  def show
    authorize person

    render 'show', locals: {
      person: person,
      versions: versions
    }
  end

  def edit
    authorize person
    @activity = params[:activity]
    person.memberships.build(group: Group.department) if person.memberships.blank?
    person.profile_photo = ProfilePhoto.new if person.profile_photo.blank?

    render 'edit', locals: {
      person: person,
      org_structure: org_structure
    }
  end

  def update
    authorize person

    result = UpdateProfile.call(
      person: person,
      person_attributes: person_params,
      profile_url: person_url(person),
      instigator: current_user
    )

    if result.success?
      type = person == current_user ? :mine : :other
      notice(:profile_updated, type, person: person)
      redirect_to person
    else
      # Work around CarrierWave keeping cached image despite failed validation
      person.profile_photo.image = nil if person.errors.include?(:'profile_photo.image')

      render 'edit', locals: {
        person: person,
        org_structure: org_structure
      }
    end
  end

  def confirm
    authorize person
    person.touch(:last_edited_or_confirmed_at) # rubocop:disable Rails/SkipsModelValidations

    notice(:profile_confirmed)
    redirect_to person
  end

  def destroy
    authorize person

    result = RemovePerson.call(person: person)

    if result.success?
      notice(:profile_deleted, person: person)

      group = person.groups.first
      redirect_to(group || home_path)
    else
      notice(:delete_error)
      redirect_to(home_path)
    end
  end

  private

  def person
    @person ||= Person.friendly.includes(:groups).find(params[:id])
  end

  def versions
    @versions ||= AuditVersionPresenter.wrap(person.versions) if policy(@person).audit?
  end

  def org_structure
    @org_structure ||= Group.hierarchy_hash
  end

  def person_params
    params.require(:person).permit(*person_params_list)
  end

  def person_params_list
    %i[
      given_name surname location_in_building city country primary_phone_number
      skype_name secondary_phone_number email contact_email
      language_intermediate language_fluent previous_positions
      other_uk other_overseas pronouns other_key_skills other_learning_and_development
      other_additional_responsibilities line_manager_id line_manager_not_required
    ] + [
      *Person::DAYS_WORKED,
      building: [], key_skills: [], learning_and_development: [], networks: [],
      key_responsibilities: [], additional_responsibilities: [], professions: [],
      memberships_attributes: %i[id role group_id leader _destroy],
      profile_photo_attributes: %i[crop_x crop_y crop_w crop_h image_cache image]
    ] + people_editor_person_params + administrator_person_params
  end

  def people_editor_person_params
    # Parameters that can only be updated by people editors, not regular users
    return [] unless current_user.role_people_editor?

    %i[ditsso_user_id]
  end

  def administrator_person_params
    # Parameters that can only be updated by administrators, not regular users
    return [] unless current_user.role_administrator?

    %i[role_administrator role_people_editor role_groups_editor ditsso_user_id grade]
  end
end
