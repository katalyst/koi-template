# syntax=docker/dockerfile:1.4

# Precompile assets in a separate container to avoid having to install nodejs in the final container
FROM public.ecr.aws/docker/library/ruby:3.2-slim AS build

# Install OS packages

ENV BUILD_PACKAGES="build-essential git curl openssh-client"
ENV DEV_PACKAGES="libcurl4-openssl-dev libpq-dev"
ENV RUBY_PACKAGES="shared-mime-info libvips"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

# Install Gems

COPY .ruby-version Gemfile* ./

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Bundle configuration
ENV BUNDLER_VERSION="2.4.13"
ENV BUNDLE_DEPLOYMENT=true
ENV BUNDLE_DISABLE_VERSION_CHECK=true
ENV BUNDLE_IGNORE_MESSAGES=true
ENV BUNDLE_JOBS=4
ENV BUNDLE_WITHOUT="development:test"

# Install gems, forwarding your ssh agent for github authentication
RUN --mount=type=ssh \
  gem install bundler -v "${BUNDLER_VERSION}" && \
  bundle install

# Compile assets

COPY --link . .

# Rails expects a database URL to be provided, but we don't actually need it to be available
ENV DATABASE_URL="postgresql://localhost"
ENV NODE_ENV=production
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE="NA"

RUN bin/rails assets:precompile && rm -rf tmp/*

# END OF BUILD ##

# Assemble all resources that will be used in the final container so they can be copied as a single layer
FROM public.ecr.aws/docker/library/ruby:3.2-slim AS base

WORKDIR /app
COPY --link . .
COPY --from=build /app/public public
COPY --from=build /app/vendor/bundle vendor/bundle
RUN mkdir -p logs tmp/cache tmp/pids tmp/sockets

# Build the app container that will run in production
FROM public.ecr.aws/docker/library/ruby:3.2-slim AS app

ARG PACKAGES="libcurl4-openssl-dev libpq-dev nginx shared-mime-info libvips"
ARG APPLICATION_VERSION
ARG APPLICATION_REVISION

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $PACKAGES && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY --from=base --link /app /app
COPY --link docker/etc/nginx.conf /etc/nginx/nginx.conf
RUN echo $APPLICATION_VERSION > VERSION && echo $APPLICATION_REVISION > REVISION

# Bundle configuration
ENV BUNDLER_VERSION="2.4.13"
ENV BUNDLE_DEPLOYMENT=true
ENV BUNDLE_DISABLE_VERSION_CHECK=true
ENV BUNDLE_WITHOUT="development:test"

ENV DATABASE_URL="postgresql://localhost"
# react-rails checks for a js runtime for jsx compilation, but we have already compiled assets
ENV EXECJS_RUNTIME="Disabled"
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT="true"
ENV RAILS_SERVE_STATIC_FILES="true"
ENV TZ="Australia/Adelaide"
ENV PUMA_PROCESSES=2
ENV PUMA_MAX_THREADS=4

EXPOSE 3000
CMD ["/app/docker/bin/web"]
