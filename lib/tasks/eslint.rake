# frozen_string_literal: true

task eslint: [:environment] do
  puts('Running ESLint...')
  system('yarn run eslint') || abort('ESLint failed')
end

task(:default).prerequisites << task(:eslint)
