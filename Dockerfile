FROM ruby:2.7.0

ENV LC_ALL=C
ENV AUTH none
ENV OUTPUT_DIR /data
ENV HTTP_PASSWORD secret
ENV HTTP_USERNAME user
ENV RACK_ENV production
ENV PORT 5000
ENV WEB_CONCURRENCY 1

RUN     apt-get update && \
        apt-get install -y --no-install-recommends ffmpeg && \
        apt-get clean && \
        wget https://yt-dl.org/latest/youtube-dl -O /usr/local/bin/youtube-dl && \
        chmod a+x /usr/local/bin/youtube-dl

WORKDIR /usr/src/app
RUN     gem install bundler:2.0.1 
COPY    Gemfile Gemfile.lock .ruby-version ./
RUN     bundle install
COPY    . .


VOLUME  /data
CMD     bundle exec unicorn --port $PORT --config-file web/unicorn.rb
