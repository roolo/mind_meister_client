# Mind Meister Ruby client

Client for API of web based and mobile mind mapping app -- [MindMeister](https://www.mindmeister.com)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mind_meister_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mind_meister_client

## Usage

I've maid one testing Rails app, and the usage was as follows.

app/controllers/application_controller.rb
~~~ruby
  before_action :setup_mm_client

  private

  def setup_mm_client
    @mm_client = MindMeisterClient::Requester.new '1625a1388f512a203faa43e8685bcdde',
                                                  '2d845879a2f2a3b1'

    @mm_client.auth_token= current_user.mm_auth_token if current_user
  end
~~~
(current_user comes from [devise](https://github.com/plataformatec/devise))

app/controllers/welcome_controller.rb

~~~ruby
def index
  begin
    @maps = @mm_client.maps_get_list
  rescue MindMeisterClient::ApiCallRequiredError => e
    redirect_to e.api_call_url
  end

end

# MindMeister will point user to this url after successful authorization
def callback
  auth_data = @mm_client.callback params[:frob]

  user = User.find_or_create_by email: auth_data[:auth][:user][:email] do |user|
    user.mm_auth_token = auth_data[:auth][:token]
    user.full_name = auth_data[:auth][:user][:fullname]
  end

  sign_in(:user, user)

  redirect_to 'index'
end
~~~

config/routes.rb
~~~ruby
root 'welcome#index'
get 'welcome/callback'

devise_for :users
~~~

app/views/welcome/index.html.erb
~~~erb
My maps

<ul>
  <% @maps[:maps][:map].each do |map_data| %>
  <li><%= map_data[:title] %> (ID: <%= map_data[:id] %>)</li>
  <% end %>
</ul>
~~~

And also there was needed migration to adjust scheme for User model
~~~ruby
def change
  change_table :users do |t|
    t.column :mm_auth_token,  :string
    t.column :full_name,      :string
  end
end
~~~

This implementation is very far from production-ready, but I hope it'll help as a quick start.

## Contributing

1. [Fork it](https://github.com/roolo/mind_meister_client/fork) ( https://github.com/roolo/mind_meister_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
