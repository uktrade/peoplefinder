# frozen_string_literal: true

class VersionsController < ApplicationController
  def index
    authorize :version, :index?
    breadcrumb :audit_trail, audit_trail_path

    versions = Version.order(created_at: :desc).page(params[:page]).per(200)

    render 'index', locals: { versions: versions }
  end

  def undo
    version = Version.find(params[:id])
    authorize version

    version.undo

    redirect_to action: :index
  end
end
