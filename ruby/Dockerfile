FROM shelvak/baseimage

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get install -qq -y ruby2.1 ruby2.1-dev zlib1g-dev \
  libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev \
  libcurl4-openssl-dev libffi-dev nodejs

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
RUN mkdir -p /bundle
ENV GEM_HOME /bundle
ENV GEM_PATH $GEM_HOME
ENV GEM_ROOT $GEM_HOME
ENV PATH $GEM_HOME/bin:$PATH
RUN gem update --system \
  && gem install bundler \
  && bundle config --global path "$GEM_HOME/" \
  && bundle config --global root "$GEM_HOME/" \
  && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

CMD ['bash']
