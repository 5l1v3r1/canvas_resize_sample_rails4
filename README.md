# Canvas Resize Sample(on Rails 4)

## Deploy

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Sample

Working sample is available at http://canvas-resize-sample-rails4.herokuapp.com/.

Please delete your photo after your testing.

## Overview

From iOS 6, photo can be uploaded from Mobile Safari, however uploading a large file takes a long time.

Resizing the file before upload can save the time and makes a big diffence in the usability.

Javascript canvasResize Plugin(http://canvasresize.gokercebeci.com/) is a very helpful library that can resize a file on client side.

This is a sample Rails app that uses Javascript canvasResize Plugin and paperclip(https://github.com/thoughtbot/paperclip) to demonstrate how to implement file resizing before upload.

## How to implement in your Rails 4 project from scratch.

To implement "file resizing before upload" in your project, follow the steps below.

### Make turbolinks off

I have not tried this sample with turbolinks on. To make it simple, just make turbolinks off.


Comment out turbolinks gem.

```
= Gemfile =

# gem 'turbolinks'
```

####

Delete:

```erb
= application.html.erb =

<%= stylesheet_link_tag    "application", media: "all", "data-turbolinks-track" => true %>
<%= javascript_include_tag "application", "data-turbolinks-track" => true %>
```

and replace with:

```erb
= application.html.erb =

<%= stylesheet_link_tag    "application", media: "all" %>
<%= javascript_include_tag "application" %>
```

Delete:

```erb
= application.js =

//= require turbolinks
```

### Copy JS files

Copy jquery.canvasResize.js and jquery.exif.js to app/assets/javascripts.

### Scaffold

```
% bundle exec rails generate scaffold Post name
```

### Add paperclip gem

Add:

```
= Gemfile =

gem 'paperclip'
```

and run:

```
% bundle install
```

Add migration by:

```
% bundle exec rails generate paperclip post picture
```

Run:

```
% bundle exec rake db:migrate
```

### Layout

Add:

```erb
= app/views/layouts/application.html.erb =

<head>
  .
  .
  <%= yield :head %>
</head>
```

### Model

Add:

```ruby
= app/models/post.rb =

attr_accessor :picture_base64
```

and papeclip methods.

```ruby
= app/models/post.rb =

has_attached_file :picture,:styles => { :thumb => "100x100#" }
validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/
```

### View

Add:

```erb
= app/views/posts/_form.html.erb =

<%- content_for :head do -%>
  <script type="text/javascript">
  $().ready(function(){
    $('input#original_post_picture').change(function(e){
      var file = e.target.files[0];
      $('canvas').remove();
      $.canvasResize(file, {
        width   : 300,
        height  : 300,
        crop    : false,
        quality : 80,
        callback: function(data, width, height){
          $('input#post_picture_base64').val(data);
        }
      });
    });
  });

  function clear_original_post_picture() {
    $('input#original_post_picture').val('');
  }
  </script>
<% end %>
```

Add:

```erb
= app/views/posts/_form.html.erb =

<%= f.hidden_field :picture_base64 %>
<%= file_field_tag 'original_post_picture' %>
```

Modify submit tag.

```erb
= app/views/posts/_form.html.erb =

onclick: "clear_original_post_picture();"
```

To enable to show picture, add:

```erb
# app/views/posts/show.html.erb

<p>
  <%= image_tag @post.picture.url %>
</p>

<p>
  <%= image_tag @post.picture.url(:thumb) %>
</p>
```

### Controller

In create action of your controller, add:

```ruby
= app/controllers/posts_controller.rb =

@post = Post.new(post_params)

if params[:post][:picture_base64].present?
  /data:image\/(.*);base64,/ =~ params[:post][:picture_base64]
  ext = $1
  data = params[:post][:picture_base64].gsub(/data:image\/.*;base64,/, '')
  file = Tempfile.new(["post_picture", ".#{ext}"])
  file.binmode
  file.write(Base64.decode64 data)
  @post.picture = file
end
```

then, close the file at the end:

```ruby
= app/controllers/posts_controller.rb =

file.close if params[:spot][:picture_base64].present?
```
