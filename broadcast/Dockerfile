FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

MAINTAINER Nestor Coppi

RUN apt-get update
RUN apt-get install -qq -y software-properties-common wget \
  gcc g++ make python-software-properties build-essential

RUN apt-add-repository ppa:brightbox/ruby-ng

RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install build-essential libasound2-dev libasound2 \
  libasound2-data module-init-tools libsndfile1-dev gstreamer0.10-alsa \
  gstreamer0.10-doc gstreamer0.10-ff* gstreamer0.10-tools gstreamer0.10-x \
  gstreamer0.10-plugins-bad gstreamer0.10-plugins-base linux-sound-base \
  gstreamer0.10-plugins-good gstreamer0.10-plugins-ugly \
  libgstreamer-plugins-base0.10-0 libgstreamer-plugins-base0.10-dev \
  libgstreamer0.10-0 libgstreamer0.10-dev  python-setuptools\
  libasound2 libasound2-plugins alsa-utils alsa-oss pulseaudio pulseaudio-utils \
  pavucontrol git-core vlc ruby2.1 ruby2.1-dev git-core curl zlib1g-dev \
  libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev \
  libcurl4-openssl-dev libffi-dev


# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem update --system \
  && gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

ENV BUNDLE_APP_CONFIG $GEM_HOME

RUN apt-get clean

RUN git clone -v https://github.com/FRM-UTN/firehouse_audio
RUN cd firehouse_audio && bundle install

RUN useradd -m vlc
RUN usermod -aG pulse,pulse-access root
RUN usermod -aG pulse,pulse-access vlc
RUN pulseaudio --system -D

EXPOSE 8000

ADD start.sh /start.sh
RUN chmod 777 /start.sh

CMD ["/start.sh"]
