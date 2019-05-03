# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :set_department_or_redirect, only: [:show]

  def show
    @all_people_count = @department.all_people_count
    @org_structure = Group.hierarchy_hash
  end

  def can_add_person_here?
    can_edit_profiles? && params['action'] == 'show'
  end

  def my_profile
    redirect_to person_path(current_user)
  end

  private

  def set_department_or_redirect
    @department = Group.department
    if @department
      # Redirect to the root department's page
      redirect_to group_path(@department)
    else
      notice :top_level_group_needed
      redirect_to(new_group_path) && return
    end
  end
end
