# frozen_string_literal: true

module Admin
  class HrDataImportsController < ApplicationController
    before_action :authorize_user

    breadcrumb 'admin.management', :admin_home_path, match: :exact
    breadcrumb 'admin.hr_data_import', :new_admin_hr_data_import

    def new; end

    def create
      if csv_file.blank?
        flash.now[:error] = 'No file uploaded'

        render :new
        return
      end

      result = ImportHrData.call(csv_file: csv_file)

      if result.success?
        flash[:notice] = 'Upload successful - profiles will be updated in the background'
        redirect_to admin_home_path
      else
        flash.now[:error] = result.error
        render :new
      end
    end

    private

    def csv_file
      params[:csv_file]
    end

    def authorize_user
      authorize :'Admin::Management', :hr_data_imports?
    end
  end
end
