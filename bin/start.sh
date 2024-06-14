#!/bin/bash

rm -f tmp/pids/server.pid
bundle exec sidekiq &
bundle exec rails s -b '0.0.0.0'