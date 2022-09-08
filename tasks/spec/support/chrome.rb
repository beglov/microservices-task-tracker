# RSpec.configure do |config|
#   config.before(:each, type: :system) do
#     if ENV["SHOW_BROWSER"] == "true"
#       driven_by :selenium_chrome
#     else
#       driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
#     end
#   end
# end


# https://avdi.codes/run-rails-6-system-tests-in-docker-using-a-host-browser/

Capybara.server_host = ENV.fetch("CAPYBARA_SERVER_HOST")
Capybara.server_port = ENV.fetch("CAPYBARA_SERVER_PORT")

RSpec.configure do |config|
  config.before :each, type: :system do
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: {
      browser: :remote,
      url: "http://host.docker.internal:9515",
    }
  end
end
