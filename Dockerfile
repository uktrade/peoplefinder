FROM ruby:2.7.3

ENV DEBIAN_FRONTEND noninteractive
ENV CHROME_VERSION stable_90.0.4430.93-1
ENV CHROMIUM_DRIVER_VERSION 90.0.4430.24



# Install dependencies & Chrome
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update \
    && apt-get -y --no-install-recommends install zlib1g-dev liblzma-dev wget xvfb unzip libgconf-2-4 libnss3 yarn
RUN wget -q https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-${CHROME_VERSION}_amd64.deb
RUN dpkg -i google-chrome-${CHROME_VERSION}_amd64.deb \
    ; apt-get -fy install

# Install Chrome driver
RUN wget -v -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/${CHROMIUM_DRIVER_VERSION}/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver.zip chromedriver -d /usr/bin/ \
    && rm /tmp/chromedriver.zip \
    && chmod ugo+rx /usr/bin/chromedriver \
    && apt-mark hold google-chrome-stable

# Get People Finder running
RUN mkdir /peoplefinder
WORKDIR /peoplefinder
COPY Gemfile /peoplefinder/Gemfile
COPY Gemfile.lock /peoplefinder/Gemfile.lock
RUN gem install bundler:2.1.4
RUN bundle install --jobs=3

COPY . /peoplefinder
