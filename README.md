# People Finder

People Finder is the people and team directory of DIT's Digital Workspace.

This repository was originally forked from
[the Ministry of Justice's People Finder](https://github.com/ministryofjustice/peoplefinder),
but has since deviated significantly in terms of functionality and purpose.

## Up and running

There is a [Docker Compose](https://docs.docker.com/compose/) configuration provided to allow for
local development in an environment as close to the production environment as possible. The
following steps are enough to get People Finder running locally:

#### Set up a `.env` file in the application root folder
```bash
cp .env.example .env
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

## Concepts

The People Finder domain revolves around three major concepts:

* **People** are DIT staff members, contractors, delivery partners, and select members of other
  government departments (essentially the largest set of people who can access internal DIT
  services using Staff SSO, see [Authentication](#authentication) below)
* **Groups** (referred to as "teams" in the frontend) are organisational units in the department
  with a tree hierarchy between them and an optional description
* **Memberships** represent the relationship between people and groups, and also contain an
  optional job title and whether or not the person is a leader of this group. People can have an
  arbitrary number of memberships (even with the same group), and a group can have an arbitrary
  number of leaders (including none).

One notable design decision in People Finder is that anyone's profile can be edited by _anyone_
else - this is intentional, and helps keep the data up to date as anyone can update errors they
might spot (and the closed, internal nature of the app and the existence of an audit trail means
malicious use isn't a big concern). 

## Authentication

In production, users authenticate using DIT's [Staff SSO](https://github.com/uktrade/staff-sso)
in order to access People Finder.

Every user in staff SSO has a unique (UUID v4) User ID (`ditsso_user_id` in the `Person` model)
that should be used to match a user to their profile on People Finder.

A common issue with this approach is that some people in the department end up with multiple SSO
profiles because they have more than one department issued email address. This results in them
having more than one profile. These accounts should be merged into one in SSO, and then one profile
on People Finder (usually the most complete one) being updated with the new SSO user ID and the
remaining People Finder profiles deleted.

When running People Finder locally, the `DEVELOPER_AUTH_STRATEGY` environment variable makes
the application mount a dummy OAuth component that allows you to manually specify an SSO User
ID, as well as a name and email as if it were passed through from Staff SSO.

## Authorization

There are three additional roles that can be assigned to people:

* **People Editor** allows this person to delete other people and edit people's SSO user ID (this
  should be assigned to members of the team handling "Has this person left the department" Zendesk
  tickets as well as profile merge requests)
* **Groups Editor** allows this person to edit/delete groups (this is currently handled by members of
  the content team)
* **Administrators** can do everything people/groups editors can, plus can see audit trails on profiles,
  and have access to a "Management" page with further functionality (and the Sidekiq admin interface)

## APIs

People Finder exposes two APIs for external integrations. These are both authenticated using
client signed JWTs (with Base64 encoded PEMs provided through environment variables, i.e. all
clients need to use the same certificate).

### Profile API
URL: `/api/v2/people_profiles/<SSO_USER_ID>`

Allows clients to retrieve profile details. This is used by Digital Workspace to retrieve the
currently logged in user's name and picture for the page header. 

Authentication is managed by public/private key pair with a JWT token being used to access the protected endpoint.

The public key is set in the env var `API_PEOPLE_PROFILES_PUBLIC_KEY`

See below for generating new public/private keys.

### Data Workspace API
URL: `/api/v2/data_workspace_export`

A paginated API providing comprehensive profile data for all people. This is ingested by
[data-flow](https://github.com/uktrade/data-flow) on a daily basis and needs to be kept up to
date when available profile fields change (as well as requiring a corresponding change in the
downstream app).

Authentication is managed by public/private key pair with a JWT token being used to access the protected endpoint.

The public key is set in the env var `API_DATA_WORKSPACE_EXPORTS_PUBLIC_KEY`

You can generate a new public and private key and JWT token using the following code:

```ruby
require 'openssl'
require 'base64'
require 'date'
require 'jwt'

key = OpenSSL::PKey::RSA.generate(2048)

# Key for supply to integrator
puts key.export

# Base 64 encoded keys
encoded_private_key = Base64.encode64(key.export)
encoded_public_key = Base64.encode64(key.public_key.export)

puts encoded_public_key # This is the value you add to API_DATA_WORKSPACE_EXPORTS_PUBLIC_KEY

now = DateTime.now
expiry = now + 1 # Add one day

# When creating a token, a payload in the following format is required
payload = { fullpath: '/api/v2/data_workspace_export', exp: expiry.to_time.to_i }

jwt_token = JWT.encode payload, key, 'RS512'

puts jwt_token

# You can decode a token in the following manner
decoded_token = JWT.decode(jwt_token, key.public_key, true, { algorithm: 'RS512' })

puts decoded_token
```

The private key should be supplied to the integrator along with instructions for generating the payload.

## External integrations

People Finder requires a number of external services to function:

### Zendesk

People Finder integrated with Zendesk using their official gem for two features:

* The "Is there something wrong with this page?" feedback form on the footer of every page
* The "Has this person left the department?" report form linked to from profile pages

### Mailchimp

People Finder integrates with Mailchimp (using the `gibbon` gem) to sync a list of email
addresses of active users (along with some profile information as tags and merge data for
segmentation purposes) to a Mailchimp audience used by Internal Communications to send
all-staff emails.

When a profile is updated, a background worker is triggered that will update (or delete if
appropriate) the relevant record on Mailchimp. Once a week, a scheduled job is triggered to
perform a wholesale synchronisation to make sure nothing has fallen through the cracks.

Tags currently include a list of domains considered "One DIT" (in the relevant `Person`
decorator) which may need to be updated when new domains "join" DIT.

### GOV.UK Notify

People Finder sends emails to users through GOV.UK Notify (using their official gem) whenever
their profile has been edited by someone other than themselves, or their profile has been
deleted.

## Background workers

People Finder uses Sidekiq for background job processing (without ActiveJob). An admin interface is
mounted at `/admin/sidekiq/` behind a route constraint to ensure only administrators can access it.

It also uses [sidekiq-scheduler](https://github.com/moove-it/sidekiq-scheduler) to enqueue
scheduled jobs (as GOV.UK PaaS deployments are ephemeral and don't provide Cron or similar).

## Use of i18n to define data

This app uses i18n translations to drive some enum-style data in profiles, e.g. the skills and
networks that users can pick from a list of checkboxes on their profile, which are then stored in
a Postgres array against the `Person` record. Adding a new one of those is as simple as adding an
appropriate key and translation to `config/locales/en.yml`. However, this means that removing an
existing key is not trivial: after removing the key from the translation file to stop it showing
up in the list of checkboxes, you then need to run a query against the DB to remove it from all
people that have it assigned already, e.g.:

```sql
UPDATE people SET networks = ARRAY_REMOVE(networks, 'some_network');
```

Otherwise the network will still show up against those people who previously had it ticked, except
it will do so with a translation error. Ideally, this should move to some sort of tagging model in
the future that allows admins to define these values in the UI instead of having it hardcoded.



## Code standards

People Finder is a large application with some degree of legacy code remaining, contributed to by
over 40 people over the space of many years. Despite extensive refactoring, some existing code may
violate the guidelines below - but all new code should meet them!

* All new code **must** pass Rubocop/ESLint/Stylelint, the configuration of which should be kept as
  close to the selected community style guides as possible
* Complex business logic workflows should live in interactors rather than controllers
  (we use the [interactors](https://github.com/collectiveidea/interactor) gem)

## Release process

Short-lived feature branches should be used, with multiple commits squashed into a descriptive
summary when merged.

Production releases should be tagged using Github's _Releases_ feature, as `vYYYY.XX` (where `YYYY`
is the current year and `XX` is an incremental version number) with a small changelog.

## Known issues/technical debt

* The test suite is reasonably exhaustive but quite brittle, and not quite as in step with the
  rewritten front-end code as it could be
* The search feature spec is known to be flaky due to the way the tests run in Elasticsearch
* API authentication is a bit complex as a result of experimenting with using client-signed JWT
  as an authentication mechanism - this should be reconsidered, especially if there is a
  department-wide agreement on internal API authentication in the future
* Groups aren't being indexed into Elasticsearch (rather they are searched through a Postgres
  `LIKE` query) which makes the search more complex and inflexible (and unforgiving of team name
  spelling mistakes) than it should be
* The "My manager" feature on the person edit page currently depends on two not-so-great hacks as
  a result of having been implemented very quickly:
    * A hacky `SearchController#people` action
    * A jQuery dependency introduced by Select2 (jQuery is not used anywhere else in People Finder)
