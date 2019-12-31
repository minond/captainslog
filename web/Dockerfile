FROM ruby:2.6.5

ENV RAILS_ENV production

RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY Gemfile* ./

RUN gem install bundler --version 2.1.0
RUN bundle install

COPY . .
