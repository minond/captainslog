FROM ruby:2.6.5

WORKDIR /usr/src/app

ENV RAILS_ENV production

RUN apt-get update \
      && apt-get install -y --no-install-recommends postgresql-client \
      && rm -rf /var/lib/apt/lists/* \
      && gem install bundler --version 2.1.0 \
      && mkdir -p log tmp public/assets

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
