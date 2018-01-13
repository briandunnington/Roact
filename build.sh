#!/usr/bin/env bash

export  APPNAME=$APPNAME \
        ROKU_DEV_TARGET=$ROKU_DEV_TARGET \
        DEVPASSWORD=$DEVPASSWORD \
        APP_KEY_PASS=$APP_KEY_PASS \
        APP_KEY_FILE=$APP_KEY_FILE \
        MAJOR=$MAJOR \
        MINOR=$MINOR \
        REVISION=$REVISION \
        ENVIRONMENT=$ENVIRONMENT

# Install rpm dependencies
rpm install -d src --hard

# Make sure tmp folder exists
mkdir tmp

# Copy correct app assests
sh set_env.sh $ENVIRONMENT

# Update manifest version numbers
host_type=`uname -s` # Determine bash env host type
if [[ "$host_type" == "Darwin" ]]; then  # Make inline sed work on both macos and linux distros
    sed -i '' -- "s/^\( *major_version=*\)[0-9][0-9]*/\1$MAJOR/" src/manifest
    sed -i '' -- "s/^\( *minor_version=*\)[0-9][0-9]*/\1$MINOR/" src/manifest
    sed -i '' -- "s/^\( *build_version=*\)[0-9][0-9]*/\1$REVISION/" src/manifest
else
    sed -i -- "s/^\( *major_version=*\)[0-9][0-9]*/\1$MAJOR/" src/manifest
    sed -i -- "s/^\( *minor_version=*\)[0-9][0-9]*/\1$MINOR/" src/manifest
    sed -i -- "s/^\( *build_version=*\)[0-9][0-9]*/\1$REVISION/" src/manifest
fi

# Re-key the device
make rekey-target

# Create the package
make pkg
