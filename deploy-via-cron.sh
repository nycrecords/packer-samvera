#! /bin/bash

#
# A little script that runs a basic test before pushing the build artifact to Vagrant Cloud.
#

# Exit script if we detect an error
set -eE

PROJECT_DIR="$(dirname ${BASH_SOURCE[0]})"

# Cleanup after errors before we exit
cleanup() {
  echo "Cleaning up after error..."

  if [[ "$PWD" == "*/vagrant/hyrax" ]]; then
    vagrant destroy -f
  fi
}

# Try to cleanup before exiting if we detect an error
trap cleanup ERR

# Make sure we're running from the right directory
cd "${PROJECT_DIR}"

# Confirm that jq is installed on the system
hash jq 2>/dev/null || {
  echo >&2 "jq must be installed to run this script: https://stedolan.github.io/jq/download/"
  exit 1
}

# Set variables from our project config file
PROJECT_OWNER=$(jq --raw-output '.project_owner' config.json)
PROJECT_NAME=$(jq --raw-output '.project_name' config.json)

# Build the base box
./build.sh base box

# Install the Hyrax application into the base box
./build.sh hyrax box

# Change into our Vagrant directory and bring up box
cd "vagrant/hyrax"
set +eE
vagrant box remove -f "${PROJECT_OWNER}/${PROJECT_NAME}" 2>&1 >/dev/null
set -eE
vagrant box add "${PROJECT_OWNER}/${PROJECT_NAME}" "../../builds/vagrant/${PROJECT_NAME}.box"
vagrant up

# Run some simple sanity checks
curl -sSf "http://localhost:8080" > /dev/null
curl -sSf "http://localhost:8984/fedora/rest" > /dev/null
curl -sSf "http://localhost:8983" > /dev/null

# Run some more sophisticated checks inside the VM
vagrant ssh -c "cd ${PROJECT_NAME}; bundle exec rake ci"

# Clean up the box
vagrant destroy -f

# Finally, do a real deploy to Vagrant Cloud
cd ../..
./deploy.sh hyrax box
