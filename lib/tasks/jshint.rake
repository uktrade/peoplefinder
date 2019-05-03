# frozen_string_literal: true

task(:default).prerequisites << task('jshint:lint') if %w[development test].include? Rails.env
