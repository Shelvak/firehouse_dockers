FROM shelvak/ruby:2.1

# Get source
WORKDIR $HOME
RUN git clone -v https://github.com/FRM-UTN/FireAlerter.git
RUN cd FireAlerter && bundle install

EXPOSE 9800:9800

WORKDIR $HOME/FireAlerter

CMD bundle exec rake
