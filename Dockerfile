FROM nbulai/ruby-chromedriver:latest

# Get People Finder running
RUN mkdir /peoplefinder
WORKDIR /peoplefinder
COPY Gemfile /peoplefinder/Gemfile
COPY Gemfile.lock /peoplefinder/Gemfile.lock
RUN bundle install

COPY . /peoplefinder
