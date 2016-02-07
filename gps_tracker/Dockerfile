FROM shelvak/ruby:2.1

# Get source
RUN git clone -v https://github.com/Shelvak/gps_tracker.git $HOME/gps_tracker

WORKDIR $HOME/gps_tracker

RUN apt-get install -y postgresql-server-dev-9.3

RUN echo 'http_proxy: http://172.17.42.1:3128' >> "$HOME/.gemrc"

RUN bundle install

EXPOSE 34567:34567

CMD bundle exec unicorn -c config/unicorn.rb
