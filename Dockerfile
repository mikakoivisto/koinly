FROM ruby:2.5
RUN gem install json
RUN apt-get update && apt-get install -y --no-install-recommends gnumeric 

ENTRYPOINT [ "ruby" ]