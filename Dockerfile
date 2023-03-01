FROM ruby:1.9.3

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
RUN mkdir -p /app

WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/

# Install dependencies
# RUN apt-get update && apt-get install -qq -y build-essential nodejs npm

RUN gem install rails -v 3.2.13
RUN bundle install

# Default command to run
CMD ["rails", "s"]

EXPOSE 3000