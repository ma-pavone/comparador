require 'cucumber'
require 'selenium-webdriver'
require 'capybara/dsl'
require 'capybara/cucumber'
require 'capybara-screenshot/cucumber'
require 'rspec'
require 'byebug'
require 'site_prism'
require 'site_prism/all_there'
require_relative './helper.rb'


World(Capybara)
# include Capybara::DSL 

opts_chrome = { browser: :chrome, options: Selenium::WebDriver::Chrome::Options.new(
    args: %w(disable-gpu start-maximized --disable-dev-shm-usage --log-level=7"))} # --auto-open-devtools-for-tabs


Capybara.register_driver :site_prism do |app|
        Capybara::Selenium::Driver.new(app, opts_chrome)
end

Capybara::Screenshot.register_driver(:selenium) do |driver, path|
    driver.browser.save_screenshot path
end

Capybara::Screenshot.webkit_options = {width: 1920, height: 1080}
Capybara::Screenshot.autosave_on_failure = false
Capybara::Screenshot.prune_strategy = :keep_last_run

Capybara.configure do |config|
    config.default_driver = :site_prism 
    config.javascript_driver = :site_prism
    config.default_max_wait_time = 9
    config.app_host = 'http://www.casasbahia.com.br/'

end

def add_browser_logs
    time_now = Time.now
    current_url = Capybara.current_url.to_s # Getting current URL
    logs = page.driver.browser.manage.logs.get(:browser).map {|line| [line.level, line.message]} # Gather browser logs
    logs.reject! { |line| ['WARNING', 'INFO'].include?(line.first) } # Remove warnings and info messages
    logs.any? === true
    embed(time_now.strftime('%Y-%m-%d-%H-%M-%S' + '\n') +
    ('URL:' + current_url + '\n') +
    logs.join("\n"), 'text/plain', 'BROWSER ERROR')
end