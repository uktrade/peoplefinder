# frozen_string_literal: true

require 'csv'

module Admin
  class DataUploadsController < ApplicationController
    before_action :authorize_user

    breadcrumb 'admin.management', :admin_home_path, match: :exact
    breadcrumb 'admin.data_upload', :new_admin_data_upload

    # TODO: Remove once all controllers use new layout
    layout 'application'

    def new
      render('new', locals: { data_upload: DataUpload.new })
    end

    def preview
      data_upload = DataUpload.new(data_upload_params)
      records = CSV.foreach(data_upload.csv_file.path, headers: true)

      records.each do |row|
        Rails.logger.info(row.inspect)
      end

      render('preview', locals: { filename: data_upload.csv_file.original_filename, records: records })
    end

    def create; end

    private

    def data_upload_params
      params.require(:data_upload).permit(:csv_file)
    end

    def authorize_user
      authorize :'Admin::Management', :data_uploads?
    end
  end
end
