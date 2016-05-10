# app.rb
require 'sinatra'
require 'line/bot'

# Constans
ARR = %w(後門, 八方雲集, 王哥肉圓, 新明羊肉羹, 火鍋, 牛排, 麥當勞, 打扣不吃飯).freeze

def client
  @client ||= Line::Bot::Client.new do |config|
    File.open('../../file', 'r') do |f|
      channel_id     = f.gets
      channel_secret = f.gets
      channel_mid    = f.gets
    end
    config.channel_id     = channel_id.sub('\n', '')
    config.channel_secret = channel_secret.sub('\n', '')
    config.channel_mid    = channel_mid.sub('\n', '')
  end
end

def key_word(usertext)
  true if usertext == '吃甚麼' || usertext == '吃什麼'
  false
end

def py_attrs(userprofilename, message)
  "nick name : #{userprofilename} \n
   text : #{message.content[:text]}\n
   mid : #{message.from_mid}"
end

def decide_food
  ARR[rand(ARR.size)]
end

post '/callback' do
  signature = request.env['HTTP_X_LINE_CHANNELSIGNATURE']
  unless client.validate_signature(request.body.read, signature)
    error 400 do
      'Bad Request'
    end
  end

  receive_request = Line::Bot::Receive::Request.new(request.env)

  receive_request.data.each do |message|
    case message.content
    when Line::Bot::Message::Text
      usertext = message.content[:text]
      user_profile = client.get_user_profile(message.from_mid)
      logger.info user_profile.contacts[0].display_name
      usertext = decide_food if key_word(usertext)
      client.send_text(
        to_mid: message.from_mid,
        text: usertext
      )
    end
  end

  userprofilename = user_profile.contacts[0].display_name
  exec('python', 'sendmsg.py', py_attrs(userprofilename, message))
end
