# People Finder

People Finder is the people and team directory of DIT's Digital Workspace.

_This README is currently being migrated over from a previous version at
[docs/Legacy_Readme.md](docs/docs/Legacy_Readme.md), which is outdated in parts, but may contain
information not included here._

## Up and running

People Finder includes a [Docker Compose](https://docs.docker.com/compose/) file to allow for local
development in an environment as close to the production environment as possible. The following
steps are enough to get People Finder running locally:

#### Set up a minimal `.env` file in the application root folder
```dosini
DEVELOPER_AUTH_STRATEGY=true
SUPPORT_EMAIL=support@example.com
PROFILE_API_TOKEN=t0ken
```

#### Build and run the containers
```bash
docker-compose build
docker-compose up
```

#### Seed database and Elasticsearch with test data
```bash
docker-compose run web bundle exec rake db:create peoplefinder:db:reload
```

#### Run the tests (optional)
```bash
docker-compose run web bundle exec rake
```

People Finder will now be accessible on http://localhost:3000. The `DEVELOPER_AUTH_STRATEGY` env
variable means the application will mount a dummy OAuth component that allows you to manually
specify a name and email, as if provided by [staff-sso](https://github.com/uktrade/staff-sso).
