# https://nicolasiensen.github.io/2022-03-11-running-rails-system-tests-with-docker/

Capybara.server_host = "0.0.0.0"
Capybara.app_host = "http://#{Socket.gethostname}:#{Capybara.server_port}"

RSpec.configure do |config|
  config.before :each, type: :system do
    driven_by :selenium, using: ENV.fetch("TEST_BROWSER").to_sym, screen_size: [1400, 1400], options: {
      browser: :remote,
      url: ENV.fetch("TEST_BROWSER_URL"),
    }
  end
end
