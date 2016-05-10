# app.rb
require 'sinatra'
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|

    channelID = ""
    channelSecret = ""
    channelMID = ""
    File.open("../../file","r") do |f|
      channelID = f.gets
      channelSecret = f.gets
      channelMID = f.gets
    end
    channelID =  channelID.sub("\n","")
    channelSecret = channelSecret.sub("\n","")
    channelMID = channelMID.sub("\n","")
    config.channel_id = channelID
    config.channel_secret = channelSecret 
    config.channel_mid = channelMID
    #config.channel_id = ENV["LINE_CHANNEL_ID"]
    #config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    #config.channel_mid = ENV["LINE_CHANNEL_MID"]
  }
end

post '/callback' do

  signature = request.env['HTTP_X_LINE_CHANNELSIGNATURE']
  unless client.validate_signature(request.body.read, signature)
    error 400 do 'Bad Request' end
  end

  receive_request = Line::Bot::Receive::Request.new(request.env)

  receive_request.data.each { |message|
    case message.content
    when Line::Bot::Message::Text
      arr = ["後門", "八方雲集", "王哥肉圓", "新明羊肉羹", "火鍋", "牛排" , "麥當勞"] 
      usertext = message.content[:text]
      if usertext === "吃甚麼" || usertext === "吃什麼"
        usertext = arr[rand(arr.length)]
      end
      user_profile = client.get_user_profile(message.from_mid)
      logger.info user_profile.contacts[0].display_name
      client.send_text(
        to_mid: message.from_mid,
        text: usertext,
      )
      userprofilename =  user_profile.contacts[0].display_name
      exec('python','sendmsg.py', "nick name : " + userprofilename + "\ntext : " + message.content[:text] + "\nmid : " +  message.from_mid )
    end
  }

  "OK"
end
