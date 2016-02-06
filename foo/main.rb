require 'bundler/setup'
Bundler.require(:default)

require 'dotenv'
Dotenv.load

require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, inspector: true)
end

Capybara.current_driver = Capybara.javascript_driver = :poltergeist

s = Capybara::Session.new(:poltergeist)
s.visit 'https://www.watashi-move.jp/pc/login.php'

s.fill_in 'loginid' , with: ENV['WM_LOGIN_ID']
s.fill_in 'password', with: ENV['WM_PASSWORD']
s.click_button 'ログインする'

sleep 2

# require 'uri'
#
# current_time = Time.now
# uri = URI.parse('https://www.watashi-move.jp/wl/mydata/body_scale.php')
# uri.query = URI.encode_www_form(targetDate: current_time.strftime('%Y/%m/%d'))
#
# s.visit uri.to_s
#
# sleep 2
#
# weight = bmi = bfp = nil
#
# s.within('#body_scaletable') do
#   # s.within(".day#{current_time.day}") do
#   s.within(".day1") do
#     s.within('.weight')  { weight = s.text }
#     s.within('.bmi')     { bmi = s.text }
#     s.within('.bodyFat') { bfp = s.text }
#   end
# end
#
# puts weight, bfp, bmi
#
# puts '*' * 20

s.visit 'https://www.watashi-move.jp/wl/home/index.php'

sleep 2

weight, bfp, bmi = s.within_frame(s.all('.gadgetFrame').last) do
  s.within('#vitals') do
    s.all('td.value').map{|e| e.all('span').first.text }
  end
end

puts weight, bfp, bmi
