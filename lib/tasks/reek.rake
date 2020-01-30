# frozen_string_literal: true

task reek: [:environment] do
  puts('Running Reek...')
  system('reek')
end

task(:default).prerequisites << task(:reek)
