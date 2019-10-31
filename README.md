# Packer Samvera

A project to build a [Samvera/Hyrax](https://github.com/samvera/hyrax) box using [Packer](https://www.packer.io/). A Hyrax project must first be "capified" to work with packer-samvera. Some initial [documentation](docs/howto-hyrax-centos.md) for this process is available. If you're looking for a project as a working example, you can check out UCLA's [Californica](https://github.com/UCLALibrary/californica/) project as an example.

There are currently three possible outputs from this Packer Samvera build:

- an AWS AMI
- an Azure Managed Image
- a Vagrant VirtualBox.

## Requirements

### General

- Bash is required to run the wrapper script.
- [Packer](https://www.packer.io/downloads.html) is required to run the build.
- [jq](https://stedolan.github.io/jq/download/) is required to work around a [Packer limitation](https://github.com/hashicorp/packer/issues/2679).

There are also some optional requirements, depending on the type of output you desire:

#### AWS

- An [AWS account](https://aws.amazon.com/)

#### Azure

- An [Azure account](https://portal.azure.com/)
- A storage account

#### Vagrant (Development Only)

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/) installed on your local machine if you want to use Vagrant

## Getting Started

Copy the `sample-config.json` file to `config.json` and add or change its variables as needed. You can skip variables that aren't relevant to your build (e.g. AWS credentials if you're building a Vagrant box).

The Packer build is basically done in two steps. The first builds a "base box" with all the necessary system dependencies installed and the second installs a Hyrax application from a GitHub repo. The default Hyrax application is DORIS Hyku.

### How to Build a Samvera-Hyrax AWS AMI (In Two Steps)

    ./build.sh base ami
    ./build.sh hyrax ami

The second step can be run independently (and repeatedly) once the first has been successfully run.

### How to Build a Samvera-Hyrax Azure Managed Image (In Two Steps)

    ./build.sh base arm
    ./build.sh hyrax arm

The second step can be run independently (and repeatedly) once the first has been successfully run.

### How to Build a Samvera-Hyrax Vagrant Box (In Two Steps)

    ./build.sh base box
    ./build.sh hyrax box

The second step can be run independently (and repeatedly) once the first has been successfully run.

### How to Use the Samvera-Hyrax Vagrant Box

The first thing you'll want to do after building is to add the box to your local Vagrant environment (using the `project_owner` and `project_name` values from your config.json file):

    cd vagrant/hyrax
    vagrant box add ${PROJECT_OWNER}/${PROJECT_NAME} ../../builds/vagrant/${PROJECT_NAME}.box

After that you can bring it up and, if you want, SSH into it:

    vagrant up
    vagrant ssh

Hyrax's Web application is exposed at <http://localhost:8080> (and at <http://localhost:3000> for those familar with Rails); Fedora is exposed at <http://localhost:8984/fcrepo/rest;> and, Solr is exposed at <http://localhost:8983/solr.>

> Hint: In case you were wondering what happened to `vagrant init` in the above steps... by changing into the `vagrant/hyrax` directory, we changed into the directory that has the box's Vagrantfile. If you use the prebuilt version of samvera-hyrax, mentioned below, you would also need to run `vagrant init` to get a local copy of the Vagrantfile.

### But I Don't Want to Build Anything

An alternative to building the Vagrant box yourself is to just use one of the prebuilt ones:

- [ksclarke/samvera-hyrax](https://app.vagrantup.com/ksclarke/boxes/samvera-hyrax) &nbsp; [[source code on GitHub](https://github.com/ksclarke/nurax)]
- [uclalibrary/californica](https://app.vagrantup.com/uclalibrary/boxes/californica) &nbsp; [[source code on GitHub](https://github.com/UCLALibrary/californica/)]

The steps to do that are pretty simple:

    mkdir vagrant-box; cd vagrant-box
    vagrant init ksclarke/samvera-hyrax
    vagrant up

If you want to use `uclalibrary/californica`, replace `ksclarke/samvera-hyrax` with that in the above example.

You can then SSH in if you want to poke around further:

    vagrant ssh

If you want to interact with the box's services, you can see the passwords for them in the sample-config.json file from this project's root directory. You can also change characteristics of the Vagrant Box (for instance, memory, etc.) in the Vagrantfile that is downloaded in the `vagrant init` step.

## Configuration

### Git

The VirtualBox VM will, by default, use the `.gitconfig` and `.gitignore` files from the developer's host system. This saves the developer from having to configure Git on the guest VM, but it does mean that there may be differences between VMs from different developers. For instance, if one developer uses a lot of Git aliases, those will only exist on their guest VM. If that developer is working on a team, it would be important not to assume that another developer is using the same Git conveniences / configuration when talking about how one uses the VM.

### Ports

The VirtualBox VM's Web, search, and repository services are exposed, externally, at different ports from the ones they run at within the virtual machine. Inside the VM, these services run at port 80 (Hyrax), port 8080 (Fedora), and port 8983 (Solr). The services are exposed at different ports outside of the VM, though, to mirror what's in the upstream developer documentation (and to mirror what developers not currently using the virtual machine will be accustomed to expect). Outside the VM, from the perspective of the developer, the ports are 8080 for the Hyrax Web application, 8984 for Fedora, and 8983 for Solr.

## Gotchas

If your build hangs at the SSH connection (fwiw, this does usually take a really long time), you might want to try using Packer [version 1.2.2](https://releases.hashicorp.com/packer/1.2.2/). I suspect there is a bug with newer Packer versions that affects some platforms. I'm going to try and create a reproducible example and file a bug report with Packer but, in the meantime, try version 1.2.2 if you run into this problem.

## License

[BSD-3-Clause](LICENSE.txt)

## Contacts

If you have any questions, suggestions, comments, etc., about the build feel free to send them to Kevin S. Clarke &lt;[ksclarke@ksclarke.io](mailto:ksclarke@ksclarke.io)</a>&gt;
