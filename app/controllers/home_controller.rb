# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    # This action should always redirect to the root group or prompt the user
    # to create one if there isn't one
    @department = Group.department

    if @department
      redirect_to group_path(@department)
    else
      notice :top_level_group_needed
      redirect_to(new_group_path) && return
    end
  end

  def my_profile
    redirect_to person_path(current_user)
  end
end
