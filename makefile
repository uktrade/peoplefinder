up:
	docker-compose up

build:
	docker-compose build --no-cache 

down:
	docker-compose down

set-up:
	docker-compose run --rm web yarn install
	docker-compose run --rm web bundle exec rake db:create db:schema:load peoplefinder:demo

test:
	docker-compose run --rm web bundle exec rake

bash:
	docker-compose run --rm web bash

migrate:
	docker-compose run --rm web bin/rails db:migrate RAILS_ENV=development

irb:
	docker-compose run --rm web bundle exec irb

index:
	docker-compose run --rm web bundle exec rake peoplefinder:reindex --trace

gemfilelock:
	docker-compose run --rm web bundle install
