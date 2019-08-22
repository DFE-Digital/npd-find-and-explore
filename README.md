# README

[![Build Status](https://dfe-ssp.visualstudio.com/S112-Find-and-Explore-Data-in-NPD/_apis/build/status/S112-Find-and-Explore-Data-in-NPD-Docker%20container-CI?branchName=master)](https://dfe-ssp.visualstudio.com/S112-Find-and-Explore-Data-in-NPD/_build/latest?definitionId=100&branchName=master)
[![Known Vulnerabilities](https://snyk.io/test/github/DFE-Digital/npd-find-and-explore/badge.svg)](https://snyk.io/test/github/DFE-Digital/npd-find-and-explore)

The Find and explore data in the National Pupil Database (NPD) service allows users to explore, search and find metadata contained in the NPD.

The NPD has over 22 million records, collected since 1995, and includes pupil level research data including demographics, attendance and exclusion records, grades, information on free school meals.

The service will allow people to get a much clearer understand of the breadth of data available.

#### Vision for this service

A clear way for users to comprehend the data they need to undertake quality research with high public benefit, whilst protecting the privacy of pupils.

## Prerequisites

#### Native

- Ruby 2.6.1
- Node ~v10
- Yarn >1.12
- PostgreSQL 10.1

#### Docker

- Docker
- Docker Compose

## Setting up the app in development

#### Native

1. Copy `.env.template` to `.env.development`, and update the database credentials to match your local setup.
2. Run `bundle install` to install the gem dependencies.
3. Run `bundle exec rails db:setup` to create a development and testing database.
4. [Import Data Tables, categories and concepts](#importing-data).
5. Run `bundle exec rails server` to launch the app on http://localhost:3000.

#### Docker

> Developing in Docker is currently quite cumbersome – the webpack build process happens for each frontend change as part of the web request, and is *very* slow. It's easier at the moment to develop natively or using a hybrid approach (detailed below).

First, copy `.env.template` to `.env.development`, and update the database password.

Run this in a shell and leave it running:

> Note: this doesn't mount your local repository into the container, so changes won't propagate across automatically.

```bash
docker-compose up --build
```

To mount your local repository into the container:

```bash
docker-compose -f docker-compose.yml -f docker-compose.development.yml up --build
```

The first time you run the app, you need to set up the databases. In a new terminal:

```bash
docker-compose run --rm web /bin/sh -c "bundle exec rails db:setup"
```

At this point you will likely want to [import Data Tables, categories and concepts](#importing-data).

Then open http://localhost:3000.

#### Hybrid

To get around the complexities of running webpacker in Docker (pull requests to resolve this welcome 😉), yarn rebuilds, etc., we can run the supporting services in Docker, and run webpacker/rails natively.

```bash
docker-compose up -d postgres postgres_test
./bin/webpack-dev-server
```

In another terminal, carry out your Rails commands as you'd expect for native development:
```bash
./bin/rails s
```

At this point you will likely want to [import Data Tables, categories and concepts](#importing-data).

Then open http://localhost:3000.


## Admin

We use the [administrate gem](https://github.com/thoughtbot/administrate) to provide an easy-to-use back-office interface to manage our data. This has it's challenges (GOV.UK styling for a start), but helps us get off the ground quickly.

The admin interface is accessible through http://localhost:3000/admin in development.

When setting up the system it is necessary to create one or more `AdminUser`s.

This can be done in the Rails console, for example:

```
> AdminUser.create!(email: 'admin@test.com', password: 'password')
```

## Running specs

```bash
bundle exec rspec
```

or within Docker:

```bash
docker-compose run --rm web /bin/sh -c "bundle exec rspec"
```

## Style & Linting

We follow the [GOV.UK style guide](https://github.com/alphagov/styleguides/blob/master/git.md), and lint with the `govuk-lint` gem, which is a wrapper around Rubocop:

```bash
bundle exec govuk-lint-ruby
```

or within Docker:

```bash
docker-compose run --rm web /bin/sh -c "bundle exec govuk-lint-ruby"
```

## Reset DB

We use custom PostgreSQL functions for search. `schema.rb` only supports structural defintions, so we must load `structure.sql` _as well_ in order to get our custom functions, e.g.:

```bash
./bin/rails db:reset
./bin/rails db:structure:load
```

> Note: if you apply migrations to a clean database this is unnecessary, as the functions are defined within the migrations as well as `structure.sql`.

## Importing data

### Importing Data Tables

Data Elements are loaded from the Excel Data Tables file, and cannot be edited within the NPD Find & Explore service. When a new version of the Data Tables is produced, this can be uploaded to the admin interface at the `/admin/data_elements/import` page.

To import the file using the CLI, use `DataTable::Upload`, as follows:

> Note that we add `;nil` to the command, otherwise you see a huge dump of all the data elements loaded in that run. We also wrap everything in a transaction so the data flips between old and new, rather than having a period with limited categories available.

```
ActiveRecord::Base.transaction do
    DataElement.delete_all
    DataTable::Upload.new(data_table: 'path/to/DataTables.xlsx')
end
```

### Importing categories and concepts

Categories and concepts should be managed through the Find & Explore admin interface (`/admin`). To manually replace the entire category and concept tree, replacing it with data from the seed Information Architecture document:

> Note that we add `;nil` to the command, otherwise you see a huge dump of all the data elements loaded in that run. We also wrap everything in a transaction so the data flips between old and new, rather than having a period with limited categories available.

```
ActiveRecord::Base.transaction do
    Concept.delete_all
    Category.delete_all
    DfEDataTables::CategoriesLoader.new('path/to/Information Architecture 04-24 - MASTER.xlsx');nil
end
```

The above should be used for seeding the initial system only, for example on the staging environment. Once data has been edited within Find & Explore, running the above command would wipe out any changes. For production migrations, consider database backup/restore.

### EditorConfig

We use [EditorConfig](https://editorconfig.org) to retain consistency beyond Rubocop. There's great support for most editors (e.g. the SublimeText plugin can auto-fix on save).

## Accessibility

Accessibility should be at the heart of what we build. As well as automated accessibility testing with [pa11y](https://github.com/pa11y/pa11y), we're carrying out ongoing accessibility-focussed user research.

## Internationalisation

The NPD only contains data on schools in England, however that doesn't mean English is the first language of researchers working on the NPD. Our first iterations are being built with English as the primary language, but we leverage the [Rails I18n API](https://guides.rubyonrails.org/i18n.html) to retain flexibility to make the Find & Explore service multilingual in future.

We use the [globalize gem](https://github.com/globalize/globalize) to provide I18n for dynamic content in models.

## Static pages

We use the [high_voltage gem](https://github.com/thoughtbot/high_voltage) to make it easy to build static pages without needing a custom controller/routes. For an example see the [service start page](app/views/pages/service_start.html.erb) and check out the documentation.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/DfE-Digital/npd-find-and-explore. This project is
intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [Contributor Covenant](CODE_OF_CONDUCT.md)
code of conduct.

### Standards & principles

There are a handful of government-specific principles and standards we strive to adhere to:

1. [The DfE Coding Principles](https://dfe-digital.github.io/technology-guidance/principles/coding-principles/#coding-principles)
2. [The GDS Service Standard](https://www.gov.uk/service-manual/service-standard), points 8, 9, and 10 are particularly pertinent. It's also worth referring to the [GDS Service Manual](https://www.gov.uk/service-manual/technology).

## CI & 3rd party services

- This source code lives in the [DfE-Digital/npd-find-and-explore](https://github.com/DfE-Digital/npd-find-and-explore) Github repo.
- CI builds happen on [Travis](https://travis-ci.com/DfE-Digital/npd-find-and-explore).
- We track code coverage with [Coveralls](https://coveralls.io/github/DfE-Digital/npd-find-and-explore).

## License

This project is made available under the terms of the [MIT License](LICENCE.md).
