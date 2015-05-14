Usage
====

Pick a "layout" from the `layouts` directory and run it with `generate_template.rb` like so:

    ruby generate_template.rb apache_proxies > apache_proxies.cfn.template

This will output the template to `apache_proxies.cfn.template`.

Note that the layout file is called `layouts/apache_proxies.json.erb` but we only specified `apache_proxies` as an argument to the tool. It will add the filename for you (and it may eventually support other serialization formats as input, like YAML).

The `snippets` directory contains partial JSON documents that should be valid in their own right after being parsed with ERB, but are mixed-in on demand into layouts or other snippets. This is accomplished with this in the .erb file (in typical ERB fashion):

    <%= snippet 'snippet_name' %>

Occasionally, snippets accept or require information to be passed into them (so they can be dynamic), and this is done via additional parameters given to the `snippet` method, like so:

    <%= snippet 'snippet_name', key: 'value', foo: 'bar' %>

This would allow, within the snippet itself, access the `params` Hash object and retrieving the specified key:

    <%= params[:key] %>

More usage info to come later...
