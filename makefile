up:
	docker-compose up

build:
	docker-compose build

down:
	docker-compose build

set-up:
	docker-compose run web yarn install
	docker-compose run web bundle exec rake db:create db:schema:load peoplefinder:demo

test:
	docker-compose run web bundle exec rake

index:
	docker-compose run web bundle exec rake peoplefinder:reindex --trace