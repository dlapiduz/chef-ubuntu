Application cookbook
====================

This cookbook is designed to be able to describe and deploy web applications. It provides the basic infrastructure; other cookbooks are required to support specific combinations of frameworks and application servers. The following cookbooks are available at this time:

* application\_java (Java and Tomcat)
* application\_nginx (nginx reverse proxy)
* application\_php (PHP with mod\_php\_apache2)
* application\_python (Django with Gunicorn)
* application\_ruby (Rails with Passenger or Unicorn)

Backward compatibility
----------------------

Previous versions of this cookbook used a set of recipes, with the configuration stored in an `apps` data bag.

This mode of operation has been DEPRECATED. The existing recipes will keep working for 3 months, and will then be removed. You are advised to upgrade your applications as soon as possible.

Requirements
============

Chef 0.10.0 or higher required (for Chef environment use).

The following Opscode cookbooks are dependencies, as this cookbook supports automating a large number of web application stacks.

* runit
* unicorn
* passenger_apache2
* tomcat
* python
* gunicorn
* apache2
* php

Deprecated Recipes
==================

The following recipes are deprecated:

* `default`
* `django`
* `gunicorn`
* `java_webapp`
* `mod_php_apache2`
* `passenger_apache2`
* `php`
* `rails`
* `tomcat`
* `unicorn`

Resources/Providers
===================

The `application` LWRP configures the basic properties of most applications, regardless of the framework or application server they use. These include:

* SCM information for the deployment, such as the repository URL and branch name;
* deployment destination, including the filesystem path to deploy to;
* any OS packages to install as dependencies;
* optional callback to control the deployment.

This LWRP uses the `deploy_revision` LWRP to perform the bulk of its tasks, and many concepts and parameters map directly to it. Check the documentation for `deploy_revision` for more information.

Configuration of framework-specific aspects of the application are performed by invoking a sub-resource; see the appropriate cookbook for more documentation.

# Actions

- :deploy: deploy an application, including any necessary configuration, restarting the associated service if necessary
- :force_deploy: same as :deploy, but it will send a :force\_deploy action to the deploy resource, directing it to deploy the application even if the same revision is already deployed

# Attribute Parameters

- name: name attribute. The name of the application you are setting up. This will be used to derive the default value for other attribute
- packages: an Array or Hash of packages to be installed before starting the deployment
- path: target path of the deployment; it will be created if it does not exist
- owner: the user that shall own the target path
- owner: the group that shall own the target path
- strategy: the underlying LWRP that will be used to perform the deployment. The default is `:deploy_revision`, and it should never be necessary to change it
- scm_provider: the provider class to use for the deployment. It defaults to `Chef::Provider::Git`, you can set it to `Chef::Provider::Subversion` to deploy from an SVN repository
- repository: the URL of the repository the application should be checked out from
- revision: an identifier pointing to the revision that should be checkout out
- deploy_key: the public key to use to access the repository via SSH
- environment: a Hash of environment variables to set while running migrations
- purge\_before\_symlink: an Array of paths (relative to the checkout) to remove before creating symlinks
- create\_dirs\_before\_symlink: an Array paths (relative to the checkout) pointing to directories to create before creating symlinks
- symlinks: a Hash of shared/dir/path => release/dir/path. It determines which files and dirs in the shared directory get symlinked to the current release directory
- symlink\_before\_migrate: similar to symlinks, except that they will be linked before any migration is run
- migrate: if `true` then migrations will be run; defaults to false
- migration_command: a command to run to migrate the application from the previous to the current state
- restart_command: a command to run when restarting the application
- environment_name: the name of a framework-specific "environment" (for example the Rails environment). By default it is the same as the Chef environment, unless it is `_default`, in which case it is set to `production`

# Callback Attributes

You can also set a few attributes on this LWRP that are interpreted as callback to be called at specific points during a deployment.
If you pass a block, it will be evaluated within a new context. If you pass a string, it will be interpreted as a path (relative to the release directory) to a file; if it exists, it will be loaded and evaluated as though it were a Chef recipe.

The following callback attributes are available:

- before\_deploy: invoked immediately after initial setup and before the deployment proper is started. This callback will be invoked on every Chef run
- before\_migrate
- before\_symlink
- before\_restart
- after\_restart

# Sub-resources

Anything that is not a known attribute will be interpreted as the name of a sub-resource; the resource will be looked up, and any nested attribute will be passed to it. More than one sub-resource can be added to an application; the order is significant, with the latter sub-resources overriding any sub-resource that comes before.

Sub-resources can set their own values for some attributes; if they do, they will be merged together with the attribute set on the main resource. The attributes that support this behavior are the following:

- environment: environment variables from the application and from sub-resources will be merged together, with later resources overriding values set in the application or previous resources
- migration_command: commands from the application and from sub-resources will be concatenated together joined with '&&' and run as a single shell command. The migration will only succeed if all the commands succeed
- restart_command: commands from the application and from sub-resources will be evaluated in order
- symlink\_before\_migrate: will be concatenated as a single array
- symlink\_before\_migrate: will be merged
- callbacks: sub-resources callbacks will be invoked first, followed by the application callbacks

Usage
=====

To use the application cookbook we recommend creating a cookbook named after the application, e.g. `my_app`. In `metadata.rb` you should declare a dependency on this cookbook and any framework cookbook the application may need. For example a Rails application may include:

    depends "application"
    depends "application_rails"

The default recipe should describe your application using the `application` LWRP; you may also include additional recipes, for example to set up a database, queues, search engines and other components of your application.

A recipe using this LWRP may look like this:

    application "my_app" do
      path "/deploy/to/dir"
      owner "app-user"
      group "app-group"

      repository "http://git.example.com/my-app.git"
      branch "production"

      rails do
        # Rails-specific configuration
      end

      passenger_apache2 do
        # Passenger-specific configuration
      end
    end

You can of course use any code necessary to determine the value of attributes:

    application "my_app" do
      repository "http://git.example.com/my-app.git"
      branch node.chef_environment == "production" ? "production" : "develop"
    end

Attributes from the application and from sub-resources are merged together:

    application "my_app" do
      restart_command "kill -1 `cat /var/run/one.pid`"
      environment "LC_ALL" => "en", "FOO" => "bar"

      rails do
        restart_command "touch /tmp/something"
        environment "LC_ALL" => "en_US"
      end

      passenger_apache2 do
        environment "FOO" => "baz"
      end
    end

    # at the end, you will have:
    #
    # restart_command #=> kill -1 `cat /var/run/one.pid` && touch /tmp/something
    # environment #=> LC_ALL=en_US FOO=baz

To use the application cookbook, we recommend creating a role named after the application, e.g. `my_app`. Create a Ruby DSL role in your chef-repo, or create the role directly with knife.

    % knife role show my_app -Fj
    {
      "name": "my_app",
      "chef_type": "role",
      "json_class": "Chef::Role",
      "default_attributes": {
      },
      "description": "",
      "run_list": [
        "recipe[my_app]"
      ],
      "override_attributes": {
      }
    }

License and Author
==================

Author:: Adam Jacob (<adam@opscode.com>)
Author:: Andrea Campi (<andrea.campi@zephirworks.com.com>)
Author:: Joshua Timberman (<joshua@opscode.com>)
Author:: Seth Chisamore (<schisamo@opscode.com>)

Copyright 2009-2012, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
