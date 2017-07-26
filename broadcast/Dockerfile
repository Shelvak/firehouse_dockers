FROM shelvak/ruby:2.1

ENV DEBIAN_FRONTEND noninteractive

MAINTAINER Nestor Coppi

RUN apt-get update
RUN apt-get install -y vlc
RUN apt-get -y clean autoclean autoremove

RUN useradd --create-home vlc

RUN apt-get install -y -qq pulseaudio
RUN echo "las"
RUN git clone -v --depth 1 https://github.com/Shelvak/firehouse_audio

RUN gem install bundler rake
RUN cd firehouse_audio && bundle install

ADD start.sh /start.sh
RUN chmod 777 /start.sh

RUN pulseaudio -D --system

CMD ["/start.sh"]
