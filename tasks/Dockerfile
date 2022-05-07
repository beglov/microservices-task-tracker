# syntax=docker/dockerfile:1
FROM ruby:3.1.2

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Upgrade RubyGems and install required Bundler version
RUN gem update --system && \
    gem install bundler

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
