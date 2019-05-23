
#! /bin/bash

# Our config file for provisioning with Vagrant
VAGRANT_CONFIG="vagrant/hyrax/vagrant-config.yaml"

# Create a config file to pass variables to Vagrantfile
echo "---" > "${VAGRANT_CONFIG}"
echo "project_name: \"${PROJECT_NAME}\"" >> "${VAGRANT_CONFIG}"
echo "project_owner: \"${PROJECT_OWNER}\"" >> "${VAGRANT_CONFIG}"
