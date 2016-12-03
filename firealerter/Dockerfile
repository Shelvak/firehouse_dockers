FROM shelvak/ruby:2.1
MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

RUN apt-get install -y git && apt-get -y clean autoclean autoremove
RUN mkdir -p /firealerter && git clone -v https://github.com/FRM-UTN/FireAlerter.git /firealerter

RUN gem install bundler

WORKDIR /firealerter
RUN bundle install

EXPOSE 9800:9800

VOLUME ['/bundle']

CMD bundle exec rake
