web: bundle exec rake db:migrate && bundle exec puma -C config/puma.rb
worker: MALLOC_ARENA_MAX=2 bundle exec sidekiq -c 5
