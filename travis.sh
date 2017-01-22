#!/usr/bin/env bash
set -e # halt script on error

echo 'Testing travis...'
bundle exec jekyll build --config _config.yml,_config_dev.yml
bundle exec htmlproofer ./_site --only-4xx --assume-extension
