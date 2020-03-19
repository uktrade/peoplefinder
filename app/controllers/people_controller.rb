# frozen_string_literal: true

class PeopleController < ApplicationController
  include StateCookieHelper

  before_action :set_person, only: %i[show edit update destroy]
  before_action :set_org_structure, only: %i[edit update add_membership]
  before_action :load_versions, only: [:show]

  # GET /people
  def index
    redirect_to '/'
  end

  # GET /people/1
  def show
    authorize @person
    delete_state_cookie
  end

  # GET /people/1/edit
  def edit
    authorize @person
    @activity = params[:activity]
    build_membership @person
  end

  # PATCH/PUT /people/1
  def update
    set_state_cookie_action_update_if_not_create
    set_state_cookie_phase_from_button
    @person.assign_attributes(person_params)
    authorize @person

    if @person.valid?
      smc = StateManagerCookie.new(cookies)
      PersonUpdater.new(
        person: @person, instigator: current_user, state_cookie: smc,
        profile_url: person_url(@person)
      ).update!
      type = @person == current_user ? :mine : :other
      notice(:profile_updated, type, person: @person) if state_cookie_saving_profile?
      redirect_to redirection_destination
    else
      render :edit
    end
  end

  # DELETE /people/1
  def destroy
    authorize @person

    destroyer = PersonDestroyer.new(@person)
    destroyer.destroy!
    notice :profile_deleted, person: @person
    group = @person.groups.first

    redirect_to group ? group_path(group) : home_path
  end

  def add_membership
    set_person if params[:id].present?
    @person ||= Person.new
    authorize @person

    render 'add_membership', layout: false
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.friendly.includes(:groups).find(params[:id])
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
    ] + super_admin_person_params
  end

  def super_admin_person_params
    # Parameters that can only be updated by super admins, not regular users
    return [] unless super_admin?

    %i[super_admin ditsso_user_id]
  end

  def set_org_structure
    @org_structure = Group.hierarchy_hash
  end

  def build_membership(person)
    person.memberships.build if person.memberships.blank?
  end

  def redirection_destination
    if state_cookie_editing_picture?
      edit_person_image_path(@person)
    elsif state_cookie_editing_picture_done?
      edit_person_path(@person)
    else
      @person
    end
  end

  def load_versions
    versions = @person.versions
    @last_updated_at = versions.last ? versions.last.created_at : nil
    @versions = AuditVersionPresenter.wrap(versions) if super_admin?
  end
end
