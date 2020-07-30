# frozen_string_literal: true

class PeopleController < ApplicationController
  include StateCookieHelper

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

  # TODO: Remove when all of app uses new layout
  layout 'application'

  def show
    authorize person
    delete_state_cookie

    render 'show', locals: {
      person: person,
      versions: versions
    }
  end

  def edit
    authorize person
    @activity = params[:activity]
    person.memberships.build(group: Group.department) if person.memberships.blank?

    render 'edit', locals: {
      person: person,
      org_structure: org_structure
    }
  end

  def update
    # TODO: Refactor state cookie logic
    set_state_cookie_action_update_if_not_create
    set_state_cookie_phase_from_button

    authorize person

    result = UpdateProfile.call(
      person: person,
      person_attributes: person_params,
      profile_url: person_url(person),
      instigator: current_user
    )

    if result.success?
      type = person == current_user ? :mine : :other
      notice(:profile_updated, type, person: person) if state_cookie_saving_profile?
      redirect_to redirection_destination
    else
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
      skype_name secondary_phone_number
      email language_intermediate language_fluent
      profile_photo_id crop_x crop_y crop_w crop_h previous_positions grade
      other_uk other_overseas pronouns other_key_skills other_learning_and_development
      other_additional_responsibilities line_manager_id line_manager_not_required
    ] + [
      *Person::DAYS_WORKED,
      building: [], key_skills: [], learning_and_development: [], networks: [],
      key_responsibilities: [], additional_responsibilities: [], professions: [],
      memberships_attributes: %i[id role group_id leader _destroy]
    ] + administrator_person_params
  end

  def administrator_person_params
    # Parameters that can only be updated by administrators, not regular users
    return [] unless current_user.role_administrator?

    %i[role_administrator role_people_editor role_groups_editor ditsso_user_id]
  end

  def redirection_destination
    if state_cookie_editing_picture?
      edit_person_image_path(person)
    elsif state_cookie_editing_picture_done?
      edit_person_path(person)
    else
      person
    end
  end
end
