# etc_environment
[![Build Status](https://travis-ci.org/locomote-cookbooks/etc_environment.png?branch=master)](https://travis-ci.org/locomote-cookbooks/etc_environment)

This cookbook populates `/etc/environment`.

# Requirements

This cookbook has been tested on CentOS and RHEL version 6.4.

# Attributes

* `node['etc_environment'] - a hash of environment variables, e.g.

```
{
  'DB_HOST'   => 'db.myapp.com',
  'NODE_ENV'  => 'production
}
```

# Usage

Just include `recipe[etc_environment]` in your run_list.

# License and Author
Author:: Chris (<chris@locomote.com>)

Copyright (c) 2013, Locomote Pty Ltd.

Licensed under BSD license.

    http://opensource.org/licenses/BSD-2-Clause
