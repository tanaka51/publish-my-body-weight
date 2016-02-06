require 'twitter'

class WeightResult < ActiveRecord::Base
  validates :weight, presence: true

  def self.fetch!
    require 'capybara/poltergeist'

    Capybara.current_driver = Capybara.javascript_driver = :poltergeist

    s = Capybara::Session.new(:poltergeist)
    s.visit 'https://www.watashi-move.jp/pc/login.php'

    s.fill_in 'loginid' , with: ENV['WM_LOGIN_ID']
    s.fill_in 'password', with: ENV['WM_PASSWORD']
    s.click_button 'ログインする'

    sleep 2

    s.visit 'https://www.watashi-move.jp/wl/home/index.php'

    sleep 2

    weight, bfp, bmi = s.within_frame(s.all('.gadgetFrame').last) do
      s.within('#vitals') do
        s.all('td.value').map{|e| e.all('span').first.text }
      end
    end

    _last = last
    if _last.weight == weight && _last.body_fat_percentage == bfp && _last.bmi == bmi
      return _last
    end

    create!(weight: weight, body_fat_percentage: bfp, bmi: bmi).publish!
  end

  def publish!
    client = twitter_client
    name = client.user.name
    regexp = /\[.*\]/

    info = "(#{weight})"
    new_name = if name.match(regexp)
                 name.gsub(regexp, info)
               else
                 name + info
               end

    if new_name.size <= 20
      client.update_profile(name: new_name)
    end

    client.update(<<-TWEET.strip_heredoc)
      weight: #{weight}kg
      body fat percentage: #{body_fat_percentage}%
      BMI: #{bmi}
    TWEET
  end

  private

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
  end
end
