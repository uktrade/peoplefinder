# People Finder

People Finder is the people and team directory of DIT's Digital Workspace.

## Up and running

People Finder includes a [Docker Compose](https://docs.docker.com/compose/) file to allow for local
development in an environment as close to the production environment as possible. The following
steps are enough to get People Finder running locally:

#### Set up a minimal `.env` file in the application root folder
```dosini
DEVELOPER_AUTH_STRATEGY=true
```

#### Build and run the containers
```bash
make build
make up
```

#### Set up assets, create database and seed test database
```bash
make set-up
```

#### Run the tests (optional)
```bash
make test
```

#### Re/index search
```bash
make index
```

### Get a list of Rake tasks

docker-compose run web bundle exec rake --tasks

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
