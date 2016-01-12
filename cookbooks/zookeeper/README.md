**Table of Contents**

- [Zookeeper](#zookeeper)
  - [Usage](#usage)
    - [Resources](#resources)
      - [zookeeper](#zookeeper)
      - [zookeeper_config](#zookeeper_config)
  - [Errata](#errata)
  - [Author and License](#author-and-license)

# Zookeeper
[Zookeeper](http://zookeeper.apache.org/) is a coordination and discovery
service maintained by the Apache Software Foundation.

This cookbook focuses on deploying Zookeeper via Chef.

## Usage
This cookbook is primarily a library cookbook. It implements a `zookeeper`
resource to handle the installation and configuration of Zookeeper. It ships
with a default recipe for backwards compatibility pre-LWRP which will work
fine, but is really just an example.

For local development, you can either use Vagrant, in which case you will need
the `vagrant-omnibus` Vagrant plugin:

`vagrant plugin install vagrant-omnibus`

Or, you can use Test-Kitchen, which will handle the bootstrapping for you, and
is the preferred method for testing this cookbook (usually via a wrapper
cookbook).

### Recipes

 * `zookeeper::default` : Installs and configures zookeeper. This does not start or manage the service.
 * `zookeeper::install` : Installs the zookeeper but does not configure it.
 * `zookeeper::config_render` : Configures zookeeper but does not install it.
 * `zookeeper::service` : Starts and manages the zookeeper service. Requires zookeeper to be installed/configured.

### Resources
This cookbook ships with one resource, with future plans for two more covering
service management and configuration rendering.

#### zookeeper
The `zookeeper` resource is responsible for installing and (eventually)
uninstalling Zookeeper from a node.

Actions: `:install`, `:uninstall`

Parameters:
* `version`: Version of Zookeeper to install (name attribute)
* `user`: The user who will eventually run Zookeeper (default: `'zookeeper'`)
* `mirror`: The mirror to obtain Zookeeper from (required)
* `checksum`: Checksum for the Zookeeper download file
* `install_dir`: Which directory to install Zookeeper to (default:
  `'/opt/zookeeper')

Example:
``` ruby
zookeeper '3.4.7' do
  user     'zookeeper'
  mirror   'http://www.poolsaboveground.com/apache/zookeeper'
  checksum '2e043e04c4da82fbdb38a68e585f3317535b3842c726e0993312948afcc83870'
  action   :install
end
```

#### zookeeper_config
This resource renders a Zookeeper configuration file. Period-delimited
parameters can be specified either as a flat hash, or by embeddeding each
sub-section within a separate hash. See the example below for an example.

Actions: `:render`, `:delete`

Parameters:
* `user`: The user to give ownership of the file to (default: `zookeeper`)
* `config`: Hash of configuration parameters to add to the file
* `path`: Path to write the configuration file to.

Example:
``` ruby
config_hash = {
  clientPort: 2181, 
  dataDir: '/mnt/zk', 
  tickTime: 2000,
  autopurge: {
    snapRetainCount: 1,
    purgeInterval: 1
  }
}

zookeeper_config '/opt/zookeeper/zookeeper-3.4.7/conf/zoo.cfg' do
  config config_hash
  user   'zookeeper'
  action :render
end
```

#### zookeeper_node
This resource can create nodes in Zookeeper.

Actions: `:create`, `:create_if_missing`, `:delete`

Parameters:
* `path`: The zookeeper node path (default: The name of the resource)
* `connect_str`: The zookeeper connection string (required)
* `data`: The data to write to the node
* `auth_scheme`: The authentication scheme (default: digest)
* `auth_cert`: The authentication password or data
* `acl_digest`: Hash of acl permissions per 'digest' id
* `acl_ip`: Hash of acl permissions per 'ip'
* `acl_sasl`: Hash of acl permissions per 'sasl' id (SASLAuthentication provider must be enabled)
* `acl_world`: Acl permissions for anyone (default: `Zk::PERM_ALL`)

Example:
``` ruby
zookeeper_node '/data/myNode' do
  action :create
  connect_str  "localhost:2181"
  data         "my data"
  auth_scheme  "digest"
  auth_cert    "user1:pwd1"
  acl_digest   "user1:a9l5yfb9zl8WCXjVmi5/XOC0Ep4=" => Zk::PERM_ALL
  acl_ip       "127.0.0.1" => Zk::PERM_READ | Zk::PERM_WRITE
  acl_sasl     "user@CHEF.IO" => Zk::PERM_ADMIN
  acl_world    Zk::PERM_NONE
end
```

## Errata
* Version 1.4.7 on the community site is in fact version 1.4.8.

## Author and License
Simple Finance <ops@simple.com>
Apache License, Version 2.0

