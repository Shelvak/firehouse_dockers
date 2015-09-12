FROM shelvak/ruby:2.1

ENV DEBIAN_FRONTEND noninteractive

MAINTAINER Nestor Coppi

RUN apt-get update
RUN apt-get install -y -qq vlc
RUN apt-get clean

RUN useradd --create-home vlc

RUN git clone https://github.com/FRM-UTN/firehouse_audio

RUN gem install bundler rake
RUN cd firehouse_audio && bundle install

ADD start.sh /start.sh
RUN chmod 777 /start.sh

CMD ["/start.sh"]
