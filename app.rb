require 'sinatra'
require 'pony'
require 'json'

class App < Sinatra::Base

  post '/contact-us' do
    body =
      <<-BODY
From: #{params['your-name']} (#{params['your-email']})

Dates Requested: #{params['DatesRequested']}

Message:
#{params['your-message']}
      BODY

    to = ['test_tourtheglades@redningja.com']
    to << 'tourtheeverglades@gmail.com' unless params.key?('test')

    Pony.mail(
      :to          => to,
      :from        => 'heroku@tourtheglades.com',
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

    content_type :json
    response.headers['Access-Control-Allow-Origin'] = 'http://tourtheglades.com'

    {
      "mailSent" => true,
      "into"     => "#wpcf7-f4-p57-o1",
      "captcha"  => nil,
      "message"  => "Your message was sent successfully. Thanks.",
    }.to_json
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
      <input type="text"   name="your-name" placeholder="Your Name"/>
      <input type="text"   name="your-email" placeholder="Email"/>
      <input type="text"   name="DatesRequested" placeholder="Dates Requested"/>
      <input type="text"   name="your-message" placeholder="Message"/>
      <input type="hidden" name="test" value="1" />
      <input type="submit" />
    </form>
    HTML
  end

end
