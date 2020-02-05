# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: %i[
    show edit update destroy all_people people_outside_subteams tree
  ]
  before_action :set_org_structure, only: %i[new edit create update]
  before_action :load_versions, only: [:show]

  # GET /groups
  def index
    @group = Group.department || Group.first
    if @group
      redirect_to @group
    else
      redirect_to new_group_path
    end
  end

  # GET /groups/1
  def show
    authorize @group
    @all_people_count = @group.all_people_count
    @people_outside_subteams_count = @group.people_outside_subteams_count

    respond_to do |format|
      format.html { session[:last_group_visited] = @group.id }
      format.js
    end
  end

  # GET /teams/slug_or_id/people
  def all_people
    @people_in_subtree = @group.all_people.paginate(page: params[:page], per_page: 500)
  end

  # GET /groups/new
  def new
    @group = collection.new
    @group.memberships.build person: person_from_person_id
    authorize @group
  end

  # GET /groups/1/edit
  def edit
    @group.memberships.build if @group.memberships.empty?
    authorize @group
  end

  # POST /groups
  def create
    @group = collection.new(group_params)
    authorize @group

    if @group.save
      notice :group_created, group: @group
      redirect_to @group
    else
      render :new
    end
  end

  # PATCH/PUT /groups/1
  def update
    authorize @group

    if @group.update(group_params)
      notice :group_updated, group: @group
      redirect_to @group
    else
      render :edit
    end
  end

  # DELETE /groups/1
  def destroy
    authorize @group

    next_page = @group.parent ? group_path(@group.parent) : groups_path
    @group.destroy
    notice :group_deleted, group: @group
    redirect_to next_page
  end

  # GET /groups/1/tree
  def tree
    @tree = @group.subtree.arrange
  end

  private

  def set_group
    group = collection.friendly.find(params[:id])
    @group = Group.includes(:people).find(group.id)
  end

  def set_org_structure
    @org_structure = Group.hierarchy_hash
  end

  def group_params
    params.require(:group)
          .permit(:parent_id, :name, :acronym, :description)
  end

  def collection
    if params[:group_id]
      Group.friendly.find(params[:group_id]).children
    else
      Group
    end
  end

  def person_from_person_id
    params[:person_id] ? Person.friendly.find(params[:person_id]) : nil
  end

  def load_versions
    versions = @group.versions
    @last_updated_at = versions.last ? versions.last.created_at : nil
    @versions = AuditVersionPresenter.wrap(versions) if super_admin?
  end
end
