# frozen_string_literal: true

task stylelint: [:environment] do
  puts('Running Stylelint...')
  system('yarn run stylelint') || abort('Stylelint failed')
end

task(:default).prerequisites << task(:stylelint)
