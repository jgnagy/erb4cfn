Usage
====

Organization
----

    .
    |-- LICENSE
    |-- README.md
    |-- generate_template.rb
    |-- layouts/
    |-- snippets/

The `layouts` directory should store the unique organizations of JSON and references to snippets used to describe and compile a CloudFormation template. This is to say that every item in `layouts` should be used to generate its own, unique CloudFormation template. Layouts can not easily be referenced by other layouts, and they can not currently be customized when compiled.

The `snippets` directory should store reusable chunks of JSON meant to be used by layouts (or other snippets). These snippets can include Ruby code and can exhibit dynamic behavior based on what options are passed to them when called.

The `generate_template.rb` command compiles a layout based on its name (passed as the only argument) into a single JSON document. The argument passed will have ".json.erb" appended to determine the name of the file under `layouts`, so only pass the name of the layout without its extension. The tool may be made smarter eventually.

Simple Usage
----

To get started, pick a "layout" from the `layouts` directory and run it with `generate_template.rb` like so:

    ruby generate_template.rb some_layout

This assumes that there is a file under `layouts` called "some_layout.json.erb", and will output the template to standard out (usually your terminal screen). It may eventually support other serialization formats as input, like YAML.

The "some_layout" layout file could simply be a normal CloudFormation template with no customizations. This won't really gain you much, but it will work, so long as the file is named appropriately. To do something interesting with the tool, use a snippet.

The `snippets` directory contains partial JSON documents that should be valid in their own right after being parsed with ERB, but are mixed-in on demand into layouts or other snippets. This is accomplished by using the `snippet()` method in your layout (in typical ERB fashion):

    <%= snippet 'snippet_name' %>

This assumes that there is a file under `snippets` called "snippet_name.json.erb". Snippets, in their simplest form, allows you to pull chunks of JSON out of a layout and move them into dedicated snippet files. This alone is a huge gain, as this allows these chunks to be reusable across multiple layouts. You can also use Ruby within the snippet to do things like iterate over a collection, insert dynamic data (like the current date and time), or calculate complex values.

Simply running `generate_template.rb` on the layout will execute all embedded Ruby and result in a static template file.

Dynamic Snippets
----

Occasionally, snippets accept or require information to be passed into them (so they can be dynamic), and this is done via additional options given to the `snippet` method in the form of a Hash with symbols for keys, like so:

    <%= snippet 'snippet_name', key: 'value', foo: 'bar' %>

This would allow, within the snippet itself, access the `params` Hash object and retrieving the specified key:

    <%= params[:key] %>

You can also use simple Ruby logic to set defaults to allow snippets to assume defaults but allow customization as required. For instance, say we have a snippet that stores a commonly used CloudFormtion Parameter, say the Instance Type. It might look something like this:

    "InstanceType" : {
      "Description" : "Server EC2 instance type",
      "Type" : "String",
      "Default" : "<%= params[:default] || 'r3.large' %>",
      "AllowedValues" : [
        "t1.micro", "t2.micro", "t2.small", "t2.medium",
        "m1.small", "m1.medium", "m1.large", "m1.xlarge",
        "m2.xlarge", "m2.2xlarge", "m2.4xlarge",
        "m3.medium", "m3.large", "m3.xlarge", "m3.2xlarge",
        "c1.medium", "c1.xlarge",
        "c3.large", "c3.xlarge", "c3.2xlarge", "c3.4xlarge", "c3.8xlarge",
        "c4.large", "c4.xlarge", "c4.2xlarge", "c4.4xlarge", "c4.8xlarge",
        "g2.2xlarge",
        "r3.large", "r3.xlarge", "r3.2xlarge", "r3.4xlarge", "r3.8xlarge",
        "i2.xlarge", "i2.2xlarge", "i2.4xlarge", "i2.8xlarge",
        "d2.xlarge", "d2.2xlarge", "d2.4xlarge", "d2.8xlarge",
        "hi1.4xlarge",
        "hs1.8xlarge",
        "cr1.8xlarge",
        "cc2.8xlarge",
        "cg1.4xlarge"
      ],
      "ConstraintDescription" : "must be a valid EC2 instance type."
    }

A careful review will reveal the following embedded Ruby:

    <%= params[:default] || 'r3.large' %>

This allows calling this snippet as-is, resulting in a sane default of "r3.large" for the parameter. However, if the snippet is called with the "default" key passed, then it will use that value instead. This might be accomplished like this:

    <%= snippet 'instance_type_parameter', default: 't2.small' %>

Snippet Sectioning
----

Using the `params[]` hash, it is possible to provide a section option when calling a snippet and use `if` and `elsif` within a snippet to only provide the requested section. This has the advantage of not creating massive snippet sprawl, and allows you to group small related sections into a single file. A single snippet can provide Parameters, Resources, Outputs, etc, this way, and just be called more than once from a layout to express them.

For example, suppose we have a snippet containing a both the parameters and resources for some subcomponent of a layout:

    <% if params[:section] == 'parameters' %>

    "WebServerPort": {
      "Description": "Web Server TCP port",
      "Type": "Number",
      "Default": "80"
    }

    <% elsif params[:section] == 'resources' %>

    "ElasticLoadBalancer" : {
      "Type" : "AWS::ElasticLoadBalancing::LoadBalancer",
      "Properties" : {
      ...

    <% else %>
      <% raise "Missing section name when calling snippet!" %>

    <% end %>

Here we used the key `section` in the `params[]` hash, but this is merely by convention and the key name is arbitrary, so long as it is properly passed when calling this snippet in the appropriate sections of the layout:

    "Parameters" : {
      <%= snippet 'snippet_name', section: 'parameters' %>
    },

    "Resources" : {
      <%= snippet 'snippet_name', section: 'resources' %>
      ...
    }

No special code was used to accomplish this; it is just one of the capabilities available when using options with snippets and ERB in general.

Contributing
====

Pull requests are welcome, though any breaking changes will be heavily reviewed.

License
====

Per the LICENSE file in this repo, this project is released under the [MIT license](http://opensource.org/licenses/MIT).
