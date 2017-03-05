# AWS-Minecraft
Use a single command to spin up a server, provision it with minecraft and start it.
If `./artifacts/world.tar.gz` exists, it will untar it as the world for the server.

When destroying infrastructure, the provisioner will recover the world from the
server to `./artifacts/world.tar.gz` (This can be done separately as desired).

## Setup
Necessary configuration before the commands will work.

### AWS credentials
This utility accesses AWS using credentials provided in an aws profile.  The
particular profile should be specified by name in `config.yml`.

### ssh-key and region
This utility associates an existing ssh key-pair with the server it spins up
and uses that key-pair to provision the server via ansible.  A path to the
key-pair should be specified under `ssh_key_path` in `config.yml`

## Commands

### `./bin/infrastructure.sh create`
Create an ec2-instances with it's own VPC and other necessary infrastructure
Executes `./bin/infrastructure.sh provision` after it completes.

### `./bin/infrastructure.sh provision`
1. Downloads and installs minecraft on the server.
2. Accepts EULA.
3. Copies commonly used script to manage minecraft as an init.d service.

### `./bin/infrastructure.sh recover-world`
tar the world/ directory of the minecraft instance on the world and store
it locally under `./artifacts/world.tar.gz`

### `./bin/infrastructure.sh destroy`
Destroy all aws infrastructure that was created in `create`. Requires an
interactive confirmation (for the moment) in order to complete.
The `destroy` command will run `recover-world` before destroying the
infrastructure.

# TODO
- Strip down the init.d script to do only what we need
- restructure ansible to castcade more naturally
- Replace relative paths
