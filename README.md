
# Secure Chat API

API for secure chatting between users

# Dependency status
[![Dependency Status](https://gemnasium.com/badges/github.com/2017NOLIFE/wisprs.svg)](https://gemnasium.com/github.com/2017NOLIFE/wisprs)

## Routes

### Application Routes

- GET `/`: main route

### Message Routes

- GET `api/v1/messages`: returns a json of all the messages
- GET `api/v1/messages/[ID]`: returns a json of all information about a message with given ID
- POST `api/v1/messages/`: creates a new message

### Public keys Routes

- GET `api/v1/public_keys`: returns a json of all the public keys
- GET `api/v1/public_keys/[ID]`: returns a json of all information about a public key with given ID
- POST `api/v1/public_keys/`: creates a new public key

## Install

Install this API by cloning the *relevant branch* and installing required gems:

    $ bundle install


## Testing

Test this API by running:

    $ RACK_ENV=test rake db:migrate
    $ bundle exec rake spec

## Develop

Run this API during development:

    $ rake db:migrate
    $ bundle exec rackup

or use autoloading during development:

    $ bundle exec rerun rackup
