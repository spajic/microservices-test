FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install --without development test
COPY . /myapp
EXPOSE 9000
ENTRYPOINT ["bundle", "exec", "ruby", "ride_price_api.rb", "-sv", "-e", "prod"]
