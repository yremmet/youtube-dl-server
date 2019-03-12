FROM ruby:latest

ENV OUTPUT_DIR /data
ENV HTTP_USERNAME user
ENV HTTP_PASSWORD secret
ENV RACK_ENV production

RUN     apt-get update && \
        apt-get install -y --no-install-recommends youtube-dl && \
        apt-get clean 

WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock .ruby-version ./
RUN gem install bundler:2.0.1 && bundle install

COPY . .

CMD ["bundle exec guard"]
