up:
	docker-compose up

build:
	docker-compose build

down:
	docker-compose down

set-up:
	docker-compose run web yarn install
	docker-compose run web bundle exec rake db:create db:schema:load peoplefinder:demo

test:
	docker-compose run web bundle exec rake

irb:
	docker-compose run web bundle exec irb

index:
	docker-compose run web bundle exec rake peoplefinder:reindex --trace

gemfilelock:
	docker-compose run web bundle install
