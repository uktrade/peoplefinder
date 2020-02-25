# frozen_string_literal: true

class VersionsController < ApplicationController
  def index
    authorize :version, :index?
    @versions = Version.order(created_at: :desc).page(params[:page]).per(200)
  end

  def undo
    @version = Version.find(params[:id])
    authorize @version
    @version.undo
    redirect_to action: :index
  end
end
