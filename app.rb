require 'sinatra'
require 'pony'

class App < Sinatra::Base

  post '/contact-us' do
    body =
      <<-BODY
  Dates Requested: #{params.fetch('DatesRequested')}

  Message:
  #{params.fetch('your-message')}
      BODY

    Pony.mail(
      #:to          => 'toddahlke@aol.com',
      :to          => 'jared@redningja.com',
      :from        => params.fetch('your-email'),
      :subject     => 'Someone filled out the contact-us form',
      :body        => body,
      :via         => :smtp,
      :via_options => {
        :address => 'smtp.sendgrid.net',
        :port => '587',
        :domain => 'heroku.com',
        :user_name => ENV['SENDGRID_USERNAME'],
        :password => ENV['SENDGRID_PASSWORD'],
        :authentication => :plain,
        :enable_starttls_auto => true,
      }
    )
  end

  get '/try' do
    base_url =
      if ENV.fetch('RACK_ENV', 'development') == 'development'
        ''
      else
        'http://tourtheglades.herokuapp.com'
      end
    url = base_url + '/contact-us'
    <<-HTML
    <form action="#{url}" method="post">
      <input type="text" name="your-name" placeholder="Your Name"/>
      <input type="text" name="your-email" placeholder="Email"/>
      <input type="text" name="DatesRequested" placeholder="Dates Requested"/>
      <input type="text" name="your-message" placeholder="Message"/>
      <input type="submit" />
    </form>
    HTML
  end

end