FROM ruby:2.3.0
RUN apt-get update -qq && apt-get install -y  --force-yes build-essential libpq-dev nodejs sqlite3 libsqlite3-dev


RUN apt-get install -y libc6-dev --force-yes
RUN apt-get install -y libevent-dev  --force-yes

RUN apt-key list | grep -A 1 expired 
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 1668892417

# Make apt non-interactive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci \
  && echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN set -ex; \
        apt-get update; \
        mkdir -p /usr/share/man/man1; \
        apt-get install -y  --force-yes --no-install-recommends \
            git mercurial xvfb \
            locales sudo openssh-client ca-certificates tar gzip parallel \
            net-tools netcat unzip zip bzip2 gnupg curl wget \
            tzdata rsync vim; \
        rm -rf /var/lib/apt/lists/*;

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Set language
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en


RUN apt-get update && apt-get install -y \
    nodejs \
    mysql-client postgresql-client sqlite3 \
    imagemagick \
    zlib1g-dev \
    --no-install-recommends --force-yes  && rm -rf /var/lib/apt/lists/*

# Create app directory
RUN mkdir -p /myapp

WORKDIR /myapp

ENV APP_HOME /myapp
# RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY . .


RUN gem install bundler:1.17.3
RUN gem install connection_pool -v 1.2.0
RUN gem install json -v=1.8.3
RUN gem install rack -v=1.2
# RUN gem install mimemagic -v=0.1.9
RUN gem install ./vendor/cache/rails-3.2.13.gem
RUN gem install ./vendor/cache/sqlite3-1.4.0.gem
RUN gem install ./vendor/cache/xmpp4r-0.5.gem
RUN gem install ./vendor/cache/net-ssh-2.6.8.gem
# RUN gem install ./vendor/cache/social_stream-2.2.2.gem
# RUN gem install ./vendor/cache/social_stream-base-2.2.2.gem --verbose
# RUN gem install ./vendor/cache/social_stream-documents-2.2.1.gem
# RUN gem install ./vendor/cache/social_stream-events-2.2.1.gem
# RUN gem install ./vendor/cache/social_stream-linkser-2.2.1.gem
# RUN gem install ./vendor/cache/social_stream-oauth2_server-2.2.2.gem
# RUN gem install ./vendor/cache/social_stream-ostatus-2.2.1.gem
# RUN gem install ./vendor/cache/social_stream-presence-2.2.1.gem


# RUN bundle outdated --only-explicit
RUN bundle _1.17.3_ install --verbose

# Default command to run
CMD ["/bin/bash"]

EXPOSE 3000