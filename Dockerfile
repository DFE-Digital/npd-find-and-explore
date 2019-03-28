# Based on https://github.com/vovimayhem/docker-compose-rails-dev-example
FROM ruby:2.6.1-alpine

RUN set -ex && apk add --update --no-cache \
											git \
                                           	build-base \
                                           	libxml2-dev \
                                           	libxslt-dev \
                                           	nodejs \
                                           	yarn \
                                           	postgresql-dev \
                                           	tzdata \
                                           	firefox-esr

# Set the working dir as HOME and add the app's binaries path to $PATH:
ENV HOME=/usr/src/app PATH=/usr/src/app/bin:$PATH

WORKDIR $HOME

ADD Gemfile* ./
RUN set -ex && bundle --retry 3

ADD package.json .
ADD yarn.lock .
RUN set -ex && yarn install

ADD . ./

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
EXPOSE 3000
