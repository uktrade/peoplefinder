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

#### Create database and seed test data
```bash
docker-compose run web bundle exec rake db:create db:schema:load peoplefinder:demo
```

#### Run the tests (optional)
```bash
docker-compose run web bundle exec rake
```

People Finder will now be accessible on http://localhost:3000.

### Authentication

In production, users authenticate using DIT's [Staff SSO](https://github.com/uktrade/staff-sso)
in order to access People Finder. This is significantly different from the built-in registration
and token process in the [MoJ People Finder](https://github.com/ministryofjustice/peoplefinder),
and all the related code has since been removed.

Every user in staff SSO has a unique (UUID v4) User ID (`ditsso_user_id` in the `Person` model)
that should be used to match a user to their profile on People Finder.

When running People Finder locally, the `DEVELOPER_AUTH_STRATEGY` environment variable makes
the application mount a dummy OAuth component that allows you to manually specify an SSO User
ID, as well as a name and email as if it were passed through from Staff SSO.
