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
                                        postgresql-client \
                                        tzdata \
                                        firefox-esr

# Set the working dir as HOME and add the app's binaries path to $PATH:
ENV HOME=/usr/src/app PATH=/usr/src/app/bin:$PATH

WORKDIR $HOME

ARG BUNDLE_WITHOUT=test:development
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

RUN gem update bundler
ADD Gemfile* ./
RUN bundle install

ADD package.json .
ADD yarn.lock .
ADD .snyk .
RUN yarn install

ADD . ./

ARG RAILS_ENV=production
ENV RAILS_ENV ${RAILS_ENV}
ENV RACK_ENV ${RAILS_ENV}
ENV NODE_ENV ${RAILS_ENV}

# Compile the webpacker/sprockets assets for production
# Note that we're using a random SECRET_KEY_BASE so we don't expose
# our production keys in CI. See https://github.com/rails/rails/issues/32947 for more.
RUN SECRET_KEY_BASE=`bin/rake secret` bin/rake assets:precompile

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
EXPOSE 3000
