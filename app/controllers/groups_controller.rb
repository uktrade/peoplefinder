# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action do
    breadcrumbs_group.ancestors.each { |ancestor| breadcrumb ancestor.short_name, ancestor }
    breadcrumb breadcrumbs_group.short_name, breadcrumbs_group, match: :exact
  end

  def show
    authorize group

    render 'show', locals: {
      group: group,
      versions: versions,
      all_people_count: group.all_people_count,
      people_outside_subteams_count: group.people_outside_subteams_count
    }
  end

  def all_people
    authorize group

    people_in_subtree = group.all_people.page(params[:page])

    render 'all_people', locals: {
      group: group,
      people_in_subtree: people_in_subtree
    }
  end

  def people_outside_subteams
    authorize group

    people = group.people_outside_subteams

    render 'people_outside_subteams', locals: {
      group: group,
      people_outside_subteams: people
    }
  end

  def new
    group = collection.new
    authorize group

    render 'new', locals: {
      group: group,
      parent_group: group.parent,
      org_structure: org_structure
    }
  end

  def edit
    authorize group

    render 'edit', locals: {
      group: group,
      parent_group: group.parent,
      org_structure: org_structure
    }
  end

  def create
    group = collection.new(group_params)
    authorize group

    if group.save
      notice :group_created, group: group
      redirect_to group
    else
      render 'new', locals: {
        group: group,
        parent_group: group.parent,
        org_structure: org_structure
      }
    end
  end

  def update
    authorize group

    if group.update(group_params)
      notice :group_updated, group: group
      redirect_to group
    else
      render 'edit', locals: {
        group: group,
        parent_group: group.parent,
        org_structure: org_structure
      }
    end
  end

  def destroy
    authorize group

    next_page = group.parent ? group_path(group.parent) : groups_path
    group.destroy
    notice :group_deleted, group: group
    redirect_to next_page
  end

  def tree
    authorize group

    render 'tree', locals: {
      group: group,
      tree: group.subtree.arrange
    }
  end

  private

  def group
    @group ||= Group.includes(:people).find_by(slug: params[:id])
  end

  def breadcrumbs_group
    @breadcrumbs_group ||= Group.find_by(slug: params[:id] || params[:group_id]) ||
                           Group.find(params.dig(:group, :parent_id))
  end

  def org_structure
    @org_structure ||= Group.hierarchy_hash
  end

  def versions
    @versions ||= AuditVersionPresenter.wrap(group.versions) if policy(group).edit?
  end

  def group_params
    params.require(:group).permit(:parent_id, :name, :acronym, :description)
  end

  def collection
    if params[:group_id]
      Group.find_by(slug: params[:group_id]).children
    else
      Group
    end
  end
end
