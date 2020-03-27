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

  # TODO: This calls these actions to memoize, move to use locals
  before_action :person, only: %i[show edit update destroy]
  before_action :org_structure, only: %i[edit update add_membership]
  before_action :versions, only: [:show]

  def show
    authorize person
    delete_state_cookie

    render 'show', locals: {
      person: person,
      versions: versions
    }, layout: 'application' # TODO: Remove when entire controller uses this layout
  end

  def edit
    authorize person
    @activity = params[:activity]
    person.memberships.build if person.memberships.blank?
  end

  def update
    set_state_cookie_action_update_if_not_create
    set_state_cookie_phase_from_button
    person.assign_attributes(person_params)
    authorize person

    if person.valid?
      smc = StateManagerCookie.new(cookies)
      PersonUpdater.new(
        person: person, instigator: current_user, state_cookie: smc,
        profile_url: person_url(person)
      ).update!
      type = person == current_user ? :mine : :other
      notice(:profile_updated, type, person: person) if state_cookie_saving_profile?
      redirect_to redirection_destination
    else
      render :edit
    end
  end

  def destroy
    authorize person

    destroyer = PersonDestroyer.new(person)
    destroyer.destroy!
    notice :profile_deleted, person: person
    group = person.groups.first

    redirect_to group ? group_path(group) : home_path
  end

  def add_membership
    person ||= Person.new
    authorize person

    render 'add_membership', layout: false
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
      primary_phone_country_code skype_name secondary_phone_number
      secondary_phone_country_code email language_intermediate language_fluent
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
