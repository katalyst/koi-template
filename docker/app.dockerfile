# syntax=docker/dockerfile:1.4

# Precompile assets in a separate container to avoid having to install node in the final container
# Using ruby default image for build and slim for final container (smaller)
FROM ruby:3.3 AS build

# Install OS packages

ENV DEBIAN_FRONTEND="noninteractive"
ENV PACKAGES="libcurl4-openssl-dev libpq-dev shared-mime-info"

RUN apt-get update && \
    apt-get install -y --no-install-recommends $PACKAGES && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

# Install Gems

COPY Gemfile* ./

# Bundle configuration
ARG BUNDLER_VERSION
ENV BUNDLE_DEPLOYMENT=true
ENV BUNDLE_IGNORE_MESSAGES=true
ENV BUNDLE_JOBS=4
ENV BUNDLE_WITHOUT="development:test"

# Install gems, forwarding your ssh agent for github authentication
RUN gem install bundler -v "${BUNDLER_VERSION}" && \
    bundle install

# Compile assets

COPY --link . .

# Rails expects a database URL to be provided but it's not required for assets compilation
ENV DATABASE_URL="postgresql://localhost"
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE="NA"

# If set, assets will be compiled into a subdirectory of public/ with this prefix
ARG CDN_ASSET_PREFIX=""

RUN bin/rails assets:precompile && rm -rf tmp/*

# END OF BUILD ##

# Copy assets to the CDN
FROM amazon/aws-cli:latest AS cdn

ARG AWS_DEFAULT_REGION="ap-southeast-2"
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG CDN_ASSET_PREFIX=""
ARG S3_ASSETS_BUCKET=""

COPY --from=build /app/public public
RUN if [ -n "$CDN_ASSET_PREFIX" ]; then \
      /usr/local/bin/aws s3 sync --only-show-errors public/$CDN_ASSET_PREFIX s3://$S3_ASSETS_BUCKET/$CDN_ASSET_PREFIX; \
    fi

# END OF CDN ##

# Assemble all resources that will be used in the final container so they can be copied as a single layer
FROM ruby:3.3-slim AS base

ARG APPLICATION_VERSION
ARG APPLICATION_REVISION

WORKDIR /app
COPY --link . .
COPY --from=build /app/vendor/bundle vendor/bundle
COPY --from=cdn /aws/public public
RUN echo $APPLICATION_VERSION > VERSION && echo $APPLICATION_REVISION > REVISION
RUN mkdir -p logs tmp/cache tmp/pids tmp/sockets

# END OF BASE ##

# Build the app container that will run in production
FROM ruby:3.3-slim AS app

ARG PACKAGES="libcurl4-openssl-dev libpq-dev nginx shared-mime-info libvips imagemagick"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $PACKAGES && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY --from=base --link /app /app
COPY --link docker/etc/nginx.conf /etc/nginx/nginx.conf

# Bundle configuration
ENV BUNDLE_DEPLOYMENT=true
ENV BUNDLE_WITHOUT="development:test"

ENV DATABASE_URL="postgresql://localhost"
ENV EXECJS_RUNTIME="Disabled"
ENV RAILS_ENV="production"
ENV TZ="Australia/Adelaide"

# Configure two puma processes, configure in terraform based on available memory
ENV PUMA_WORKERS=2
ENV PUMA_MAX_THREADS=5

ARG CDN_ASSET_PREFIX
ENV CDN_ASSET_PREFIX=$CDN_ASSET_PREFIX

# precompile ruby code with bootsnap so that container can start faster (~3s)
RUN bundle exec bootsnap precompile --gemfile app/ lib/

EXPOSE 3000
CMD ["/app/docker/bin/web"]
