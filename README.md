# puppet-lint duplicate_class_parameters check

A puppet-lint extension that ensures class parameter names are unique.

[![Build Status](https://travis-ci.org/deanwilson/puppet-lint_duplicate_class_parameters-check.svg?branch=master)](https://travis-ci.org/deanwilson/puppet-lint_duplicate_class_parameters-check)

Until Puppet 3.8.5 it was possible to have the same parameter name specified
multiple times in a class definition without error. This could cause
confusion as only the last value for that name was taken and it was decided in
[No error on duplicate parameters on classes and resources](https://tickets.puppetlabs.com/browse/PUP-5590)
that this behaviour should change and now return an error. This `puppet-lint`
plugin will help you catch those issues before you upgrade and suffer failures
in your puppet runs.

An exaggerated example of the previously valid, but awkward, behaviour can be found below -

    class file_resource(
      $duplicated = { 'a' => 1 },
      $duplicated = 'foo',
      $not_unique = 'bar',
      $not_unique = '2nd bar',
      $unique     = 'baz'
    ) {

      file { '/tmp/my-file':
        mode => '0600',
      }

    }

With this extension installed `puppet-lint` will return

    found duplicate parameter 'duplicated' in class 'file_resource'

## Installation

To use this plugin add the following line to your Gemfile

    gem 'puppet-lint-duplicate_class_parameters-check'

and then run `bundle install`

## Other puppet-lint plugins

You can find a list of my `puppet-lint` plugins in the
[unixdaemon puppet-lint-plugins](https://github.com/deanwilson/unixdaemon-puppet-lint-plugins) repo.

### Author
[Dean Wilson](http://www.unixdaemon.net)
